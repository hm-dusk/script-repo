#!/bin/bash

# ###
# 脚本说明：对多个节点进行统一执行命令脚本
# author：hm
# version: 1.0
# use: ./xxx.sh "free -h"
# description：
# 脚本后接一个参数，表示要执行的命令
# ###

# 接收命令内容
cmd=$@
# 节点数组
servers="cdh1 cdh2 cdh3"
for s in ${servers} ; do
   tput setaf 3
   echo  "========== $s =========="
   tput setaf 7
   ssh -4 ${s} "source /etc/profile ; ${cmd}"
done