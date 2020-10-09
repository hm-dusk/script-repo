#! /bin/bash

# ###
# 为所有节点配置离线yum源（Configure offline yum source for all nodes）
# author：hm
# version: 1.0
# use: ./xxx.sh
# description：
# 1、当前节点配置过离线repo，且当前节点为yum离线源提供方，也就是需要该节点运行过1.yum-repo.sh脚本（The current node is configured with an offline repo, and the current node is the yum offline source provider, which means that the node needs to run the 1.yum-repo.sh script）
# 2、需要xcall.sh脚本，且放到了/usr/bin/目录下（Requires xcall.sh script and is placed in the / usr / bin / directory）
# 3、需要xscp.sh脚本，且放到了/usr/bin/目录下（Requires xscp.sh script and placed it in the / usr / bin / directory）
# ###

# 获取当前路径（Get the current path）
current_path=$(cd "$(dirname $0)";pwd)

# 将当前节点下配置好的repo拷贝出来（Copy the repo configured under the current node）
mv /etc/yum.repos.d/iso.repo ${current_path}/

# 将所有节点/etc/yum.repos.d/目录下所有repo文件备份（Back up all repo files in the /etc/yum.repos.d/ directory of all nodes）
xcall.sh mkdir -p /etc/yum.repos.d/repo-back
xcall.sh mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/repo-back/

# 将配置好的repo分发到所有节点（Distribute the configured repo to all nodes）
xscp.sh ${current_path}/iso.repo /etc/yum.repos.d/

# 为保证所有节点能访问到httpd服务节点，需要关闭防火墙（To ensure that all nodes can access the httpd service node, you need to turn off the firewall）
systemctl stop firewalld

# 所有节点刷新yum缓存（All nodes refresh the yum cache）
xcall.sh "yum clean all;yum makecache"
