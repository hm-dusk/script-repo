#!/bin/bash
# 脚本说明：将磁盘分区挂载到目录，并修改fstab文件，达到开机自动挂载的效果（通过磁盘UUID挂载）
# 使用方式：./mount-device-uuid-to-fstab.sh /dev/vdb1 /opt
# 脚本后面接两个参数，第一个参数为磁盘名，第二个参数为需要挂载到的目录

# 第一个参数，需要挂载的磁盘分区，例如/dev/vdb1
device=$1
# 第二个参数，要挂载到的目录，例如/opt
dir=$2

# 得到磁盘分区的UUID
uuid=$(lsblk -o UUID $device | sed -n '2p')
# 得到磁盘分区的类型
type=$(lsblk -o FSTYPE $device | sed -n '2p')

# 将挂载命令拼接到fstab文件后面，默认采用noatime模式：https://wiki.archlinux.org/index.php/Fstab_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)#atime_%E5%8F%82%E6%95%B0
echo UUID=$uuid $dir  $type  defaults,noatime  1 2 >> /etc/fstab