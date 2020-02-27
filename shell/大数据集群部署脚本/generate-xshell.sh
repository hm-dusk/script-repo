#!/bin/bash

# ###
# 生成xcall.sh、xscp.sh工具()
# xcall.sh为所有节点执行命令脚本
# xscp.sh为拷贝文件到所有节点脚本
# author：hm
# version: 1.0
# use: xxx.sh hostFilename
# description：
# 1、需提供主机名信息文件hostname.txt，格式如下 (Need to provide the hostname information file hostname.txt, the format is as follows)：
# [ip1] [hostname1] [short hostname1] [password1]
# [ip2] [hostname2] [short hostname2] [password2]
# ###

# 获取数据文件名（Get data file name）
filename=$1

# 遍历数据文件，得到所有节点的短域名（）
cat ${filename} | while read ip host short pwd; do
  hosts="$hosts $short"
done

echo "result is ${hosts}"
