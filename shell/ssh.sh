#!/bin/bash
# 安装ssh服务
yum -y install openssh-server openssh-clients

# 创建目录，以免sshd启动报错
mkdir /var/run/sshd/

# 设置UsePAM为no
# sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config

# 创建公共秘钥
ssh-keygen -t rsa -P '' -f /etc/ssh/ssh_host_rsa_key
ssh-keygen -t dsa -P '' -f /etc/ssh/ssh_host_dsa_key
ssh-keygen -t ecdsa -P '' -f /etc/ssh/ssh_host_ecdsa_key
ssh-keygen -t ed25519 -P '' -f /etc/ssh/ssh_host_ed25519_key

# 启动sshd服务
/usr/sbin/sshd -D&