#! /bin/bash

# ###
# 配置集群主机名和免密登录脚本(Configure a cluster password-free login script)
# author：hm
# version: 1.0
# use: xxx.sh hostFilename
# description：
# 1、需提供主机名信息文件hostname.txt，格式如下 (Need to provide the hostname information file hostname.txt, the format is as follows)：
# [ip1] [hostname1] [sort hostname1] [password1]
# [ip2] [hostname2] [sort hostname2] [password2]
# ###

# 获取数据文件名
filename=$1

# 所有节点修改hosts文件，增加host映射
cat ${filename} | while read ip1 host1 sort1 pwd1; do
  ssh -f -o StrictHostKeyChecking=no root:${pwd1}$@${ip1} "hostnamectl set-hostname $host1"
  cat ${filename} | while read ip2 host2 sort2 pwd2; do
    ssh -f -o StrictHostKeyChecking=no root:${pwd1}@${ip1} "echo $ip2 $host2 $sort2 >> /etc/hosts"
  done
done
tput setaf 3
echo "=====主机名、host文件配置完成！(Host name, host file configuration is complete!)====="
tput setaf 7

# 所有节点生成秘钥文件(Generate a key file for all nodes)
cat ${filename} | while read ip host sort pwd; do
  ssh -f -o StrictHostKeyChecking=no root:${pwd}@${ip} "ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa"
done

# 将每个节点的id拷贝到所有节点的authorized_keys文件中(Copy the id of each node into the authorized_keys file of all nodes)
cat ${filename} | while read ip1 host1 sort1 pwd1; do
  cat ${filename} | while read ip2 host2 sort2 pwd2; do
    ssh -f -o StrictHostKeyChecking=no root@${ip1} "sshpass -p $pwd2 ssh-copy-id -f $ip2 2>/dev/null"
  done
done
tput setaf 3
echo "=====免密登录完成！(Secret-free login is complete!)====="
tput setaf 7