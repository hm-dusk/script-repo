#! /bin/bash

# ###
# 为当前节点配置离线yum源（Configure offline yum source for the current node）
# author：hm
# version: 1.0
# use: ./xxx.sh xxx.iso
# description：
# 需提供当做yum源的iso文件（Need to provide iso file as yum source）
# ###

# 获取iso文件名（Get iso file name）
filename=$1
# 获取本机ip地址（Get the local IP address）
ip_addr=$(hostname -I | awk '$1=$1')

################################## 1.生成本地临时仓库（Generate a local temporary repository） ################################################
# 挂载到本地目录（Mount to local directory）
mkdir -p /var/www/html/iso
echo "Start moving iso file ..."
mv ./${filename} /var/www/html/
mount -o loop -t iso9660 /var/www/html/${filename} /var/www/html/iso

# 将原本的所有repo文件备份（Back up all original repo files）
echo "Start backing up repo files ..."
mkdir -p /etc/yum.repos.d/repo-back
mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/repo-back/

# 配置本地repo文件（Configure local repo file）
cat >/etc/yum.repos.d/iso.repo<< EOF
[iso]
name=${filename}
baseurl=file:///var/www/html/iso
gpgcheck=0
enabled=1
EOF

# 刷新yum缓存（Refresh yum cache）
yum clean all;yum makecache

##################################### 2.制作httpd仓库（Making the httpd repository） ################################################
# 安装httpd服务（Install httpd service）
yum -y install httpd

# 修改配置文件，使其支持.parcel格式（Modify the configuration file to support the .parcel format）
sed -i 's/AddType application\/x-gzip .gz .tgz/AddType application\/x-gzip .gz .tgz .parcel/g' /etc/httpd/conf/httpd.conf

# 启动httpd服务（Start httpd service）
systemctl enable httpd
systemctl start httpd

# 将repo文件内容改为http的源路径（Change the content of the repo file to the source path of http）
cat >/etc/yum.repos.d/iso.repo<< EOF
[iso]
name=${filename}
baseurl=http://${ip_addr}/iso
gpgcheck=0
enabled=1
EOF

# 刷新yum缓存（Refresh yum cache）
yum clean all;yum makecache
