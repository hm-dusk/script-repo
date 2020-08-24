#!/bin/bash

# ###
# hive 修复数据库下所有表分区（hive repairs all table partitions under the database）
# author：hm
# version: 1.0
# use: ./xxx.sh
# description：
# 需要更改hive连接参数和库名（Need to change hive connection parameters and library name）
# ###

hive_url="jdbc:hive2://localhost:10000"
database="iot"

# 得到数据库下所有表名（Get all table names under the database）
beeline -u ${hive_url} -n hive --outputformat=csv2 --showHeader=false -e "show tables in ${database};" >.table_name.tmp
echo -e '\n'

# 循环读取表名进行修复操作（Read the table name cyclically for repair operation）
while read -r tname; do
  beeline -u ${hive_url} -n hive -e "MSCK REPAIR TABLE ${database}.${tname};"
  echo -e '\n'
done <.table_name.tmp

# 删除临时文件
rm -f .table_name.tmp
