#!/bin/bash

# ###
# CDH集群环境初始化
# author：hm
# version: 1.0
# use: ./xxx.sh
# description：
# 1、需要集群提前做好免密登录
# 2、需要xcall.sh脚本，且放到了/usr/bin/目录下
# 3、需要xscp.sh脚本，且放到了/usr/bin/目录下
# ###

# 关闭防火墙
xcall.sh "systemctl stop firewalld"
xcall.sh "systemctl disable firewalld"

# 禁用SELinux
xcall.sh "setenforce 0"
xcall.sh "sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config"

# 设置SWAP
xcall.sh "sysctl -w vm.swappiness=1"
xcall.sh "echo 'vm.swappiness = 1' >> /etc/sysctl.conf"

# 关闭透明大页面
xcall.sh "echo never > /sys/kernel/mm/transparent_hugepage/enabled"
xcall.sh "echo never > /sys/kernel/mm/transparent_hugepage/defrag"
cat >>/etc/rc.d/rc.local<< EOF
if test -f /sys/kernel/mm/transparent_hugepage/enabled; then
   echo never > /sys/kernel/mm/transparent_hugepage/enabled
fi
if test -f /sys/kernel/mm/transparent_hugepage/defrag; then
   echo never > /sys/kernel/mm/transparent_hugepage/defrag
fi
EOF
xscp.sh /etc/rc.d/rc.local /etc/rc.d/
xcall.sh "chmod +x /etc/rc.d/rc.local"

# 配置时钟同步
xcall.sh "yum -y install ntp"


