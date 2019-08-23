#!/bin/bash
# 脚本说明：对磁盘进行格式化分区脚本
# 使用方式：./part-device.sh sdb sdc sdd sde
# 脚本后面接一个参数，表示需要格式化的磁盘名，可以添加多个磁盘，以空格分开

# 接收的参数，多个磁盘用空格分开
device=$@
for d in $device;  
do
echo -e '\n\n\n'
echo ===$d start===

echo ===删除原有分区===
parted /dev/$d rm 1

echo ===格式化分区表为gpt===
parted /dev/$d mktable gpt yes;

echo ===创建分区,2k对齐===
parted /dev/$d mkpart 1 2048s 100%;

echo ===对齐检查===
parted /dev/$d align-check opt 1;

echo ===分区格式化===
mkfs.xfs -f /dev/$d'1';

echo ===展示分区结果===
parted /dev/$d print

echo ===$d end===;
echo -e '\n\n\n'
done  
