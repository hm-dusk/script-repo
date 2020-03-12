#!/bin/bash

# ###
# 初始化CDH集群元数据库Mariadb，包括新建库、用户等（Initialize the CDH cluster metadata database Mariadb, including new libraries, users, etc.）
# author：hm
# version: 1.0
# use: ./xxx.sh password init.sql mysql-connector-java-5.1.47.jar
# description：
# 1、需要初始化sql脚本文件（Need to initialize sql script file）
# 2、需要mysql连接jar包文件（Need mysql connection jar package file）
# 3、脚本后面接3个参数，第一个为Mariadb的root密码，第二个为需要执行的初始化sql脚本，第三个为mysql连接jar包（The script is followed by 3 parameters, the first is Mariadb's root password, the second is the initialization sql script that needs to be executed, and the third is the mysql connection jar package）
# 4、需要xcall.sh脚本，且放到了/usr/bin/目录下（Requires xcall.sh script and is placed in the / usr / bin / directory）
# 5、需要xscp.sh脚本，且放到了/usr/bin/目录下（Requires xscp.sh script and placed it in the / usr / bin / directory）
# ###

# 数据库root密码（Database root password）
password=$1

# 需要执行的sql脚本（SQL script to be executed）
sql=$2

# mysql连接包（mysql connection package）
connect_jar=$3

# 初始化CDH Database（Initialize CDH Database）
mysql -uroot -p${password} < ./${sql}

# 规范连接包名称（Canonical connection package name）
mv ${connect_jar} mysql-connector-java.jar

# 将连接包分发到所有节点（Distribute the connection package to all nodes）
xcall.sh "rm -rf /usr/share/java"
xcall.sh "mkdir -p /usr/share/java"
xscp.sh ./mysql-connector-java.jar /usr/share/java/