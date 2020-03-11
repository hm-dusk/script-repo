#!/bin/bash

# ###
# 生成xcall.sh、xscp.sh工具脚本（Generate xcall.sh, xscp.sh tool scripts）
# xcall.sh为所有节点执行命令脚本（xcall.sh executes command script for all nodes）
# xscp.sh为拷贝文件到所有节点脚本（xscp.sh is a script to copy files to all nodes）
# author：hm
# version: 1.0
# use: xxx.sh hostFilename
# description：
# 1、需提供主机名信息文件hostname.txt，格式如下 (Need to provide the hostname information file hostname.txt, the format is as follows)：
# [ip1] [hostname1] [short hostname1] [password1]
# [ip2] [hostname2] [short hostname2] [password2]
# 2、注意hostname.txt文件最后一行末尾必须要有一个换行符，不然最后一行识别不到。（Note that there must be a line break at the end of the last line of the hostname.txt file, otherwise the last line is not recognized.）
# ###

# 获取数据文件名（Get data file name）
filename=$1

hosts=""

# 遍历数据文件，得到所有节点的短域名（Traverse the data file to get the short domain names of all nodes）
while read ip host short pwd; do
  hosts="$hosts $short"
done < ${filename}

################################## 1.生成xcall.sh脚本（Generate xcall.sh script）##################################
rm -f ./xcall.sh
rm -f /usr/bin/xcall.sh
cat >./xcall.sh<< EOF
#!/bin/bash

# ###
# 对多个节点进行统一执行命令脚本（Unified execution of command scripts on multiple nodes）
# author：hm
# version: 1.0
# use: ./xxx.sh "free -h"
# description：
# 脚本后接一个参数，表示要执行的命令（The script is followed by a parameter indicating the command to be executed）
# ###

# 接收命令内容（Receive command content）
cmd=\$@
# 节点数组（Node array）
servers="${hosts}"
for s in \${servers} ; do
   tput setaf 3
   echo  "========== \$s =========="
   tput setaf 7
   ssh -4 \${s} "source /etc/profile ; \${cmd}"
done
EOF
chmod +x xcall.sh
# 将脚本拷贝到/usr/bin目录下
cp ./xcall.sh /usr/bin/

################################## 2.生成xscp.sh脚本（Generate xscp.sh script）##################################
rm -f ./xscp.sh
rm -f /usr/bin/xscp.sh
cat >./xscp.sh<< EOF
#!/bin/bash

# ###
# 分发文件到各个节点（Distributing files to various nodes）
# author：hm
# version: 1.0
# use: ./xxx.sh test.txt /opt/test/
# description：
# 脚本后接两个参数，第一个表示需要分发的文件，第二个表示分发到的目录（The script is followed by two parameters, the first represents the file to be distributed, and the second represents the directory to which it is distributed）
# ###

# 需要发送的文件名（File name to send）
filename=\$1
# 需要发送到的目录（Directory to send to）
path=\$2
# 节点数组（Node array）
servers="${hosts}"

for s in \${servers} ; do
   tput setaf 3
   echo  "========== \$s =========="
   tput setaf 7
   scp \${filename} \${s}:\${path}
done
EOF
chmod +x xscp.sh
# 将脚本拷贝到/usr/bin目录下
cp ./xscp.sh /usr/bin/