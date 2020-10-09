#!/bin/bash

# ###
# 配置java环境变量（Configure java environment variables）
# author：hm
# version: 1.0
# use: ./xxx.sh
# description：
# 1、需要xcall.sh脚本，且放到了/usr/bin/目录下（Requires xcall.sh script and is placed in the / usr / bin / directory）
# 2、需要xscp.sh脚本，且放到了/usr/bin/目录下（Requires xscp.sh script and placed it in the / usr / bin / directory）
# ###

# 安装jdk
# Install jdk
xcall.sh "yum -y install oracle-j2sdk1.8"

# 配置环境变量
# Configure environment variables
xcall.sh "echo '# Java environment variables' >> /etc/profile"
xcall.sh "echo 'export JAVA_HOME=/usr/java/jdk1.8.0_181-cloudera' >> /etc/profile"
xcall.sh "echo 'export CLASSPATH=\$JAVA_HOME/lib/' >> /etc/profile"
xcall.sh "echo 'export PATH=\$PATH:\$JAVA_HOME/bin' >> /etc/profile"
xcall.sh "source /etc/profile"
source /etc/profile