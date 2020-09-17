#!/bin/bash

# ###
# hive生成库下所有表的建表语句（Table creation statement for all tables under the hive generation library）
# author：hm
# version: 1.0
# use: ./xxx.sh
# description：
# 需要更改hive连接参数和库名（Need to change hive connection parameters and library name）
# ###

hive_url="jdbc:hive2://zqnode2:10000"
database="iot"

# 得到数据库下所有表名（Get all table names under the database）
beeline -u ${hive_url} -n hive --outputformat=csv2 --showHeader=false -e "show tables in ${database};" >.table_name.tmp
echo -e '\n'

# 循环读取表名进行查看建表语句操作（Read the table name in a loop to view the table creation statement operation）
while read -r tname; do
  beeline -u ${hive_url} -n hive --outputformat=csv2 --showHeader=false -e "show create table ${database}.${tname};" >> all_table.sql
  echo -e '\n' >> all_table.sql
done < .table_name.tmp
