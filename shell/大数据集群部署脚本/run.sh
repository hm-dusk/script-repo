#! /bin/bash

iso_file_name="CentOS-7-x86_64-Everything-1810.iso"
host_name_file="hostname.txt"
net_mask="255.255.255.0"
mariadb_conf="my.cnf"
mariadb_root_paaaword="1234"
mariadb_scm_paaaword="1234"
mariadb_init_sql="init.sql"
cm="cm6.3.0"
cdh="cdh6.3.0"

sh 1.yum-repo.sh ${iso_file_name}

sh 2.ssh-all.sh ${host_name_file}

sh 3.generate-xshell.sh ${host_name_file}

sh 4.yum-repo-all-host.sh

sh 5.init-cdh-env.sh

sh 6.config-ntp.sh ${host_name_file} ${net_mask}

sh 7.install-mariadb.sh ${mariadb_conf} ${mariadb_root_paaaword}

sh 8.init-mariadb.sh ${mariadb_root_paaaword} ${mariadb_init_sql} mysql*.jar

sh 9.cdh-yum-repo.sh ${cm} ${cdh}

sh 10.install-cloudera-manager.sh ${mariadb_scm_paaaword}