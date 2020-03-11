#! /bin/bash

# ###
# 配置集群主机名和免密登录脚本(Configure a cluster password-free login script)
# author：hm
# version: 1.0
# use: ./xxx.sh hostFilename
# description：
# 1、需提供主机名信息文件hostname.txt，格式如下 (Need to provide the hostname information file hostname.txt, the format is as follows)：
# [ip1] [hostname1] [short hostname1] [password1]
# [ip2] [hostname2] [short hostname2] [password2]
# 2、注意hostname.txt文件最后一行末尾必须要有一个换行符，不然最后一行识别不到。（Note that there must be a line break at the end of the last line of the hostname.txt file, otherwise the last line is not recognized.）
# ###

# 获取数据文件名（Get data file name）
filename=$1

# 检测是否安装expect
if [[ ! -e /usr/bin/expect ]]
 then  yum -y install expect
fi

# 所有节点修改主机名、hosts文件（Modify the host name and hosts file for all nodes）
cat ${filename} | while read ip1 host1 short1 pwd1; do
expect << EOF
  spawn ssh root@${ip1} "hostnamectl set-hostname ${host1}"
  expect {
  "yes/no" {send "yes\r"; exp_continue}
  "password" {send "${pwd1}\r"}
  }
  expect eof
EOF
# 在当前节点hosts文件中增加host映射（Add host mapping in hosts file of current node）
  cat ${filename} | while read ip2 host2 short2 pwd2; do
expect << EOF
  spawn ssh root@${ip1} "echo ${ip2} ${host2} ${short2} >> /etc/hosts"
  expect {
  "yes/no" {send "yes\r"; exp_continue}
  "password" {send "${pwd1}\r"}
  }
  expect eof
EOF
  done
done

tput setaf 3
echo "=====主机名、host文件配置完成！(Host name, host file configuration is complete!)====="
tput setaf 7

# 所有节点生成秘钥文件(Generate a key file for all nodes)
cat ${filename} | while read ip host short pwd; do
expect << EOF
  spawn ssh root@${short} "ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa"
  expect {
  "yes/no" {send "yes\r"; exp_continue}
  "password" {send "${pwd}\r"}
  }
  expect eof
EOF
done

# 将所有节点的key文件内容添加到本地临时authorized_keys文件
touch ./authorized_keys
cat ${filename} | while read ip host short pwd; do
# 复制节点的key文件到本地
expect << EOF
  spawn scp ${short}:/root/.ssh/id_rsa.pub ./${short}.pub
  expect {
  "yes/no" {send "yes\r"; exp_continue}
  "password" {send "${pwd}\r"}
  }
  expect eof
EOF
# 将key文件内容添加到本地临时authorized_keys文件中
cat ./${short}.pub >> ./authorized_keys
# 删除临时key文件
rm -f ./${short}.pub
done

# 将组装好的authorized_keys文件分发到所有节点
cat ${filename} | while read ip host short pwd; do
expect << EOF
  spawn scp ./authorized_keys ${short}:/root/.ssh/
  expect {
  "yes/no" {send "yes\r"; exp_continue}
  "password" {send "${pwd}\r"}
  }
  expect eof
EOF
done
# 删除临时authorized_keys文件
rm -f ./authorized_keys

tput setaf 3
echo "=====免密登录完成！(Secret-free login is complete!)====="
tput setaf 7