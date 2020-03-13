#!/bin/bash

# ###
# 集群配置NTP时钟同步（Cluster configuration NTP clock synchronization）
# author：hm
# version: 1.0
# use: ./xxx.sh hostname.txt 192.168.136.2 255.255.255.0
# description：
# 1、需要集群提前做好免密登录（Require the cluster to do secret login in advance）
# 2、需要集群每个节点配置好离线yum源（Need to configure offline yum source for each node in the cluster）
# 3、需要xcall.sh脚本，且放到了/usr/bin/目录下（Requires xcall.sh script and is placed in the / usr / bin / directory）
# 4、需要xscp.sh脚本，且放到了/usr/bin/目录下（Requires xscp.sh script and placed it in the / usr / bin / directory）
# 5、需提供主机名信息文件hostname.txt，格式如下 (Need to provide the hostname information file hostname.txt, the format is as follows)：
# [ip1] [hostname1] [short hostname1] [password1]
# [ip2] [hostname2] [short hostname2] [password2]
# 6、需要3个参数，第1个为hostname.txt文件，第2个为网关地址，第3个为子网掩码（Requires 3 parameters, the first is the hostname.txt file, the second is the gateway address, and the third is the subnet mask）
# ###

# 获取数据文件名
# Get data file name
filename=$1
# 获取网关地址
# Get gateway address
gateway_addr=$2
# 获取子网掩码
# Get subnet mask
net_mask=$3

## 保证已经安装ntp服务
## Ensure that the NTP service is installed
xcall.sh "yum -y install ntp"



## 各节点配置
while read ip host short pwd; do
sed '12 arestrict ${gateway_addr} mask ${net_mask} nomodify notrap' -i /etc/ntp.conf
sed '12 arestrict ${ip} nomodify notrap nopeer noquery' -i /etc/ntp.conf
cat >> /etc/ntp.conf<<EOF
restrict ${ip} nomodify notrap nopeer noquery  # ip地址为本机主机ip
restrict ${gateway_addr} mask ${net_mask} nomodify notrap  # 网关地址和子网掩码
EOF
done < ${filename}


