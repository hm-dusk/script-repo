#!/bin/bash

# ###
# 脚本说明：分发文件到各个节点
# author：hm
# version: 1.0
# use: ./xxx.sh test.txt /opt/test/
# description：
# 脚本后接两个参数，第一个表示需要分发的文件，第二个表示分发到的目录
# ###

# 需要发送的文件名
filename=$1
# 发送到的目录
path=$2
# 节点数组
servers="cdh1 cdh2 cdh3"

for s in ${servers} ; do
   tput setaf 3
   echo  "========== $s =========="
   tput setaf 7
   scp ${filename} ${s}:${path}
done