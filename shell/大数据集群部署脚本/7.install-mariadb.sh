#!/bin/bash

# ###
# 安装CDH集群元数据库Mariadb（Install CDH cluster metadata database Mariadb）
# author：hm
# version: 1.0
# use: ./xxx.sh my.cnf password
# description：
# 脚本后面接两个参数，第一个为Mariadb配置文件，第二个为Mariadb的root密码（The script is followed by two parameters, the first is the Mariadb configuration file, and the second is the Mariadb root password）
# ###

# Mariadb配置文件名（Mariadb configuration file name）
config_file=$1
# 数据库root密码（Database root password）
password=$2

# 安装server（Install server）
yum -y install mariadb-server

# 替换/etc/my.cnf配置文件（Replace /etc/my.cnf configuration file）
mv /etc/my.cnf /etc/my.cnf.bak
cp ./${config_file} /etc/

# 启动Mariadb（Start Mariadb）
systemctl start mariadb
systemctl enable mariadb

# 初始化Mariadb（Initialize Mariadb）
if [[ ! -e /usr/bin/expect ]]
 then  yum -y install expect
fi
expect << EOF
  spawn mysql_secure_installation
  expect {
  "enter for none" { send "\r"; exp_continue}
  "Y/n" { send "Y\r" ; exp_continue}
  "password\:" { send "${password}\r"; exp_continue}
  "Cleaning up" { send "\r"}
  }
  expect eof
EOF