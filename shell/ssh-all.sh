#! /bin/bash

# ###
# 配置集群免密登录脚本(Configure a cluster password-free login script)
# author：hm
# version: 1.0
# use: xxx.sh [node1,node2,node3] [password]
# description：
# 1、主机需安装sshpass (The host needs to install sshpass)
# 2、各主机需要添加host映射到各自的hosts文件中 (Each host needs to add host mapping to its own hosts file)
# ###

HOSTS=$1
PASSWD=$2

# 所有节点生成秘钥文件(Generate a key file for all nodes)
for node in $HOSTS ; do
  sshpass -p $PASSWD ssh -o StrictHostKeyChecking=no root@$node "ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa"
done

# 将每个节点的id拷贝到所有节点的authorized_keys文件中(Copy the id of each node into the authorized_keys file of all nodes)
for node in $HOSTS ; do
  for node2 in $HOSTS ; do
    sshpass -p $PASSWD ssh -o StrictHostKeyChecking=no root@$node "sshpass -p Cdacoo_2019 ssh-copy-id $node2"
  done
done

echo "免密登录完成！(Secret-free login is complete!)"