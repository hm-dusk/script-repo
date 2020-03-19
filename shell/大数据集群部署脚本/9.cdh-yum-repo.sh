#!/bin/bash

# ###
# 为当前节点配置离线cm源和cdh源（Configure offline cm source and cdh source for the current node）
# author：hm
# version: 1.0
# use: ./xxx.sh cm6.3.0 cdh6.3.0
# description：
# 1、需要提供cm源文件夹、cdh源文件夹（Need to provide cm source folder, cdh source folder）
# 2、一般在node1执行，也就是配置httpd服务的节点（Generally executed on node1, that is, the node that configures the httpd service）
# 3、脚本后面接2个参数，第一个为cm源文件夹，包含cloudera manager一系列rpm安装包；第二个为cdh源文件夹，包含cdh的parcel文件（The script is followed by 3 parameters, the first is the cm source folder, which contains a series of rpm installation packages for cloudera manager; the second is the cdh source folder, which contains the parcel file of the cdh）
# ###

# Cloudera Manager安装包目录
# Cloudera Manager installation package directory
cm_rpm=$1
# CDH parcel目录
# CDH parcel directory
cdh_parcel=$2
# 本机ip地址，安装httpd服务节点的ip地址
# Local IP address, the IP address of the node where the httpd service is installed
ip_addr=$(hostname -I)

# 将目录拷贝到/var/www/html/目录下
# Copy the directory to the / var / www / html / directory
cp -r ${cm_rpm} ${cdh_parcel} /var/www/html/

# 配置cm-repo文件
# Configure cm-repo file
cat >/etc/yum.repos.d/cm.repo<< EOF
[cm]
name=${cm_rpm}
baseurl=http://${ip_addr}/${cm_rpm}
gpgcheck=0
enabled=1
EOF

# 将配置好的repo分发到所有节点
# Distribute the configured repo to all nodes
xscp.sh /etc/yum.repos.d/cm.repo /etc/yum.repos.d/

# 所有节点刷新yum缓存
# All nodes refresh the yum cache
xcall.sh "yum clean all;yum makecache"