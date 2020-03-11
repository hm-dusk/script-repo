#! /bin/bash

# ###
# 为所有节点配置离线yum源（Configure offline yum source for all nodes）
# author：hm
# version: 1.0
# use: ./xxx.sh hostname.txt
# description：
# 1、需提供当做yum源的iso文件
# 2、需要提供本机ip地址
# ###

# 获取数据文件名（Get data file name）
filename=$1

# 将所有节点/etc/yum.repos.d/目录下所有repo文件备份
while read ip host short pwd; do
    mkdir -p /etc/yum.repos.d/repo-back
    mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/repo-back/
done < ${filename}

