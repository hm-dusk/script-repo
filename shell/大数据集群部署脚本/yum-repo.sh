#! /bin/bash

# ###
# 配置离线yum源
# author：hm
# version: 1.0
# use: ./xxx.sh xxx.iso 192.168.1.1
# description：
# 1、需提供当做yum源的iso文件
# 2、需要提供本机ip地址
# ###

# 获取iso文件名
filename=$1
# 获取本机ip地址
ip_addr=$2
# 获取当前路径
current_path=$(cd "$(dirname $0)";pwd)

################################## 1.生成本地临时仓库 ################################################
# 挂载到本地目录
mkdir -p /var/www/html/iso
mv ./${filename} /var/www/html/
mount -o loop -t iso9660 /var/www/html/${filename} /var/www/html/iso

# 将原本的所有repo文件备份
mkdir ${current_path}/repo-back
mv /etc/yum.repos.d/* ${current_path}/repo-back

# 配置本地repo文件
cat >/etc/yum.repos.d/iso.repo<< EOF
[iso]
name=${filename}
baseurl=file:///var/www/html/iso
gpgcheck=0
enabled=1
EOF

# 刷新yum缓存
yum clean all;yum makecache

# 将备份的repo文件移到/etc/yum.repo.d/目录
mv ${current_path}/repo-back /etc/yum.repos.d/

##################################### 2.制作httpd仓库 ################################################
# 安装httpd服务
yum -y install httpd

# 修改配置文件，使其支持.parcel格式
sed -i 's/AddType application\/x-gzip .gz .tgz/AddType application\/x-gzip .gz .tgz .parcel/g' /etc/httpd/conf/httpd.conf

# 启动httpd服务
systemctl start httpd

# 将repo文件内容改为http的源路径
cat >/etc/yum.repos.d/iso.repo<< EOF
[iso]
name=${filename}
baseurl=http://${ip_addr}/iso
gpgcheck=0
enabled=1
EOF

# 刷新yum缓存
yum clean all;yum makecache
