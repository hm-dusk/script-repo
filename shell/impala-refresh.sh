#!/bin/bash

# ###
# impala refresh刷新库下所有表脚本（impala refresh refresh all table scripts under the library）
# author：hm
# version: 1.0
# use: ./xxx.sh
# description：
# 需要更改impala连接参数和库名（Need to change impala connection parameters and library name）
# ###

impala_url="bd-master3:25003"
database="iot"

# 得到数据库下所有表名（Get all table names under the database）
impala-shell -i ${impala_url} -q "show tables in ${database};" -o .table_name.tmp --delimited
echo -e '\n'

# 循环读取表名进行refresh操作
while read tname; do
  impala-shell -i ${impala_url} -q "refresh ${database}.${tname};"
  echo -e '\n'
done <.table_name.tmp

# 删除临时文件
rm -f .table_name.tmp
