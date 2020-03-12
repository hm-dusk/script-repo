#!/bin/bash

# ###
# 安装启动Cloudera Manager服务（Install and start Cloudera Manager service）
# author：hm
# version: 1.0
# use: ./xxx.sh password
# description：
# 1、需要一个参数，元数据库（MySQL/Mariadb）中scm库的scm用户的密码，在init.sql脚本中指定（Requires one parameter, the password of the scm user of the scm library in the meta database (My SQL / Mariadb), specified in the init.sql script）
# ###

# 数据库scm用户密码
# Database scm user password
password=$1

# 安装jdk
# Install jdk
yum -y install oracle-j2sdk1.8

# 安装Cloudera Manager Server以及Agent
# Install Cloudera Manager Server and Agent
yum -y install cloudera-manager-daemons cloudera-manager-agent cloudera-manager-server

# 初始化Cloudera Manager数据库
# Initialize the Cloudera Manager database
/opt/cloudera/cm/schema/scm_prepare_database.sh mysql scm scm
expect << EOF
  spawn /opt/cloudera/cm/schema/scm_prepare_database.sh mysql scm scm
  expect {
  "password" {send "${password}\r"; exp_continue}
  }
  expect eof
EOF

# 启动Cloudera Manager Server
# Start Cloudera Manager Server
systemctl start cloudera-scm-server

# 查看日志
# View log
tput setaf 3
echo "运行以下命令以查看启动日志："
echo "tail -f /var/log/cloudera-scm-server/cloudera-scm-server.log"
tput setaf 7