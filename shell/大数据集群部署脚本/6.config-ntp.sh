#!/bin/bash

# ###
# 集群配置NTP时钟同步（Cluster configuration NTP clock synchronization）
# author：hm
# version: 1.0
# use: ./xxx.sh hostname.txt 255.255.255.0
# description：
# 1、需要集群提前做好免密登录（Require the cluster to do secret login in advance）
# 2、需要集群每个节点配置好离线yum源（Need to configure offline yum source for each node in the cluster）
# 3、需提供主机名信息文件hostname.txt，格式如下 (Need to provide the hostname information file hostname.txt, the format is as follows)：
# [ip1] [hostname1] [short hostname1] [password1]
# [ip2] [hostname2] [short hostname2] [password2]
# 4、需要2个参数，第1个为hostname.txt文件，第2个为子网掩码（Requires 2 parameters, the first is the hostname.txt file, and the second is the subnet mask）
# ###

# 获取数据文件名
# Get data file name
filename=$1
# 获取子网掩码
# Get net mask
net_mask=$2
# 获取网关地址
# Get gateway address
gateway_addr=$(ip r | grep default | awk '{print $3}')
# 获取本机ip地址
# Get the local IP address
ip_addr=$(hostname -I | awk '$1=$1')

# 配置所有节点
# Configure all nodes
while read ip host short pwd; do
ssh -f root@${ip} "yum -y install ntp"
ssh -f root@${ip} "sed \"12 arestrict ${gateway_addr} mask ${net_mask} nomodify notrap\" -i /etc/ntp.conf"
ssh -f root@${ip} "sed \"12 arestrict ${ip} nomodify notrap nopeer noquery\" -i /etc/ntp.conf"

ssh -f root@${ip} "sed \"s/server/#server/\" -i /etc/ntp.conf"

ssh -f root@${ip} "sed \"26 aFudge ${ip_addr} stratum 10\" -i /etc/ntp.conf"
ssh -f root@${ip} "sed \"26 aserver ${ip_addr}\" -i /etc/ntp.conf"
done < ${filename}

# 修改本机节点为ntp主服务器
# Modify the local node as the NTP master server
sed "s/server ${ip_addr}/server 127.127.1.0/" -i /etc/ntp.conf
sed "s/Fudge ${ip_addr} stratum 10/Fudge 127.127.1.0 stratum 10/" -i /etc/ntp.conf

# 所有节点启动ntp服务
# All nodes start ntp service
while read ip host short pwd; do
ssh -f root@${ip} "systemctl enable ntpd"
ssh -f root@${ip} "systemctl start ntpd"
done < ${filename}
