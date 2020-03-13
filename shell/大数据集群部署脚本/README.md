# 说明
该目录中所有脚本均为部署CDH集群过程中需要的脚本，脚本执行顺序按照脚本前缀排列

# 脚本说明
## 0.1.part-device.sh
分区脚本

## 0.2.mount-device-uuid-to-fstab.sh
开机自动挂载分区脚本

## 1.yum-repo.sh
一般在node1节点执行，用于安装配置离线Centos Everthing的yum源

## 2.ssh-all.sh
一般在node1节点执行，用于配置集群所有节点免密登录

## 3.generate-xshell.sh
一般在node1节点执行，用于生成`xcall.sh`（所有节点执行命令脚本）、`xscp.sh`（拷贝文件到所有节点脚本）两个脚本

## 4.yum-repo-all-host.sh
一般在node1节点执行，而且node1必须执行过`1.yum-repo.sh`脚本，用于配置所有节点离线yun源

## 5.init-cdh-env.sh
一般在node1节点（有`xcall.sh`、`xscp.sh`脚本的主机）执行，用于初始化CDH部署环境

## 6.config-ntp.sh
配置NTP时钟同步（未完成）

## 7.install-mariadb.sh
在需要安装元数据库的节点运行，用于安装元数据库（Mariadb）

## 8.init-mariadb.sh
初始化CDH元数据库，包括新建库、用户、分发mysql连接jar包等，需要`init.sql`脚本

## 9.cdh-yum-repo.sh
配置Cloudera Manager、CDH parcel yum仓库源

## 10.install-cloudera-manager.sh
安装Cloudera Manager服务

# 配置文件说明
## hostname.txt
需要提前配置好，格式为：
```markdown
[ip1] [hostname1] [short hostname1] [password1]
[ip2] [hostname2] [short hostname2] [password2]

```
> 注意：最后一行末尾必须要有换行符，不然最后一行识别不到。

## my.cnf
Mariadb配置文件

## init.sql
安装Mariadb后需要执行的初始化sql脚本
用户创建CDH需要的库和用户，其中密码需要根据实际情况进行修改
