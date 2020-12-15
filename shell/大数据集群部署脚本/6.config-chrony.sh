#!/bin/bash

# ###
# 集群使用chrony配置NTP时钟同步（The cluster uses chrony to configure NTP clock synchronization）
# author：hm
# version: 1.0
# use: ./xxx.sh hostname.txt
# description：
# 1、需要集群提前做好免密登录（Require the cluster to do secret login in advance）
# 2、需要集群每个节点配置好离线yum源（Need to configure offline yum source for each node in the cluster）
# 3、需要xcall.sh脚本，且放到了/usr/bin/目录下（Requires xcall.sh script and is placed in the / usr / bin / directory）
# 4、需提供主机名信息文件hostname.txt，格式如下 (Need to provide the hostname information file hostname.txt, the format is as follows)：
# [ip1] [hostname1] [short hostname1] [password1]
# [ip2] [hostname2] [short hostname2] [password2]
# 5、需要1个参数，为hostname.txt文件（1 parameter is required, which is the hostname.txt file）
# ###

# 获取数据文件名
# Get data file name
filename=$1

# 获取本机ip地址
# Get the local IP address
ip_addr=$(hostname -I | awk '$1=$1')
ip_addr_3=$(echo ${ip_addr%.*})

# 安装chrony服务
# Install chrony service
xcall.sh "yum -y install chrony"

# 配置所有节点
# Configure all nodes
while read ip host short pwd; do

ssh -f root@${ip} "sed \"s/server/#server/\" -i /etc/chrony.conf"
ssh -f root@${ip} "sed \"6 aserver ${ip_addr} iburst \" -i /etc/chrony.conf"

done < ${filename}

# 修改本机节点为chrony主服务器
# Modify the local node as the chrony master server
sed "s/#allow 192.168.0.0/allow ${ip_addr_3}/" -i /etc/chrony.conf
sed "s/#local/local/" -i /etc/chrony.conf

# 所有节点启动chrony服务
# All nodes start chrony service
while read ip host short pwd; do
ssh -f root@${ip} "systemctl enable chronyd;systemctl start chronyd"
done < ${filename}
