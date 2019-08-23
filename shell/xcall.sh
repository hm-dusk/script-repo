#!/bin/bash
# 脚本说明：对多个节点进行统一执行命令脚本
# 使用方式：./xcall.sh "free -h"
# 脚本后接一个参数，表示要执行的命令

# 接收命令内容
cmd=$@
# 节点数组
servers="HDP-master1 HDP-master2 hdp-master3 HDP-node1 HDP-node2 HDP-node3"
for s in $servers ; do
   tput setaf 3
   echo  "========== $s =========="
   tput setaf 7
   ssh -4 $s "source /etc/profile ; $cmd"
done