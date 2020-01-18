#!/bin/bash
# 安装ssh服务
yum -y install openssh-server openssh-clients

# 创建目录，以免sshd启动报错
mkdir /var/run/sshd/

# 设置UsePAM为no
# sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config

# 创建公共秘钥
ssh-keygen -t rsa -P '' -f /etc/ssh/ssh_host_rsa_key
ssh-keygen -t dsa -P '' -f /etc/ssh/ssh_host_dsa_key
ssh-keygen -t ecdsa -P '' -f /etc/ssh/ssh_host_ecdsa_key
ssh-keygen -t ed25519 -P '' -f /etc/ssh/ssh_host_ed25519_key

# 启动sshd服务
/usr/sbin/sshd -D&


##################  ssh-all.sh
#!/bin/bash
passwd=$@

# 配置免密登录
sshpass -p $passwd ssh -o StrictHostKeyChecking=no root@master "cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys"
# 复制master秘钥到slave001
sshpass -p $passwd scp -o StrictHostKeyChecking=no /root/.ssh/authorized_keys root@slave001:/root/.ssh
sshpass -p $passwd ssh -o StrictHostKeyChecking=no root@slave001 "cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys"

# 这一步的目的是在slave001上连接一下master，让known_hosts文件记录master的秘钥
sshpass -p $passwd ssh -o StrictHostKeyChecking=no root@slave001 "sshpass -p $passwd scp -o StrictHostKeyChecking=no /root/.ssh/authorized_keys root@master:/root/.ssh"

# 复制master和slave001的秘钥到slave002
sshpass -p $passwd ssh -o StrictHostKeyChecking=no root@slave001 "sshpass -p $passwd scp -o StrictHostKeyChecking=no /root/.ssh/authorized_keys root@slave002:/root/.ssh"
sshpass -p $passwd ssh -o StrictHostKeyChecking=no root@slave002 "cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys"
# 将包含三个节点的秘钥文件拷贝到每个节点
sshpass -p $passwd ssh -o StrictHostKeyChecking=no root@slave002 "sshpass -p $passwd scp -o StrictHostKeyChecking=no /root/.ssh/authorized_keys root@master:/root/.ssh"
sshpass -p $passwd ssh -o StrictHostKeyChecking=no root@slave002 "sshpass -p $passwd scp -o StrictHostKeyChecking=no /root/.ssh/authorized_keys root@slave001:/root/.ssh"


echo "免密登录完成！"


###################### zk-init.sh
#!/bin/bash
ssh master "echo 1 > /home/zookeeper/myid"
ssh slave001 "echo 2 > /home/zookeeper/myid"
ssh slave002 "echo 3 > /home/zookeeper/myid"


# base_hbase 基本hbase环境
# 自动生成hbase环境
FROM cyanidehm/base_java:0.1

MAINTAINER cyanidehm <1322260665@qq.com>

# 将hadoop复制到容器内
COPY ./hbase-1.4.6 /opt/hbase-1.4.6
COPY ./zookeeper-3.4.10 /opt/zookeeper-3.4.10
COPY ./ssh-all.sh /home
COPY ./xzk-cluster.sh /home
COPY ./zk-init.sh /home

# 创建软链接
RUN ln -s /opt/hbase-1.4.6 /home/hbase;ln -s /opt/zookeeper-3.4.10 /home/zookeeper

# 添加环境变量，刷新配置文件
RUN echo "export HBASE_HOME=/home/hbase" >> /etc/profile;echo "export PATH=\$PATH:\$HBASE_HOME/bin" >> /etc/profile;echo "export ZK_HOME=/home/zookeeper" >> /etc/profile;echo "export PATH=\$PATH:\$ZK_HOME/bin" >> /etc/profile;source /etc/profile

# 关闭防火墙
# RUN systemctl stop firewalld;systemctl disable firewalld

# 暴露22端口
EXPOSE 22


###################### run-wordcount.sh
#!/bin/bash

# test the hadoop cluster by running wordcount

# create input files
mkdir input
echo "Hello Docker" >input/file2.txt
echo "Hello Hadoop" >input/file1.txt

# create input directory on HDFS
hadoop fs -mkdir -p input

# put input files to HDFS
hdfs dfs -put ./input/* input

# run wordcount
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/sources/hadoop-mapreduce-examples-2.7.2-sources.jar org.apache.hadoop.examples.WordCount input output

# print the input files
echo -e "\ninput file1.txt:"
hdfs dfs -cat input/file1.txt

echo -e "\ninput file2.txt:"
hdfs dfs -cat input/file2.txt

# print the output of wordcount
echo -e "\nwordcount output:"
hdfs dfs -cat output/part-r-00000

###################### startnode.sh
#!/usr/bin/env bash
sed -i "s/@HDFS_MASTER_SERVICE@/$HDFS_MASTER_SERVICE/g" $HADOOP_HOME/etc/hadoop/core-site.xml
sed -i "s/@HDOOP_YARN_MASTER@/$HDOOP_YARN_MASTER/g" $HADOOP_HOME/etc/hadoop/yarn-site.xml
yarn-master
HADOOP_NODE="${HADOOP_NODE_TYPE}"
if [ $HADOOP_NODE = "datanode" ]; then
        echo "Start DataNode ..."
        hdfs datanode  -regular

else
        if [  $HADOOP_NODE = "namenode" ]; then
                echo "Start NameNode ..."
        hdfs namenode
        else
                if [ $HADOOP_NODE = "resourceman" ]; then
                        echo "Start Yarn Resource Manager ..."
            yarn resourcemanager
                else

             if [ $HADOOP_NODE = "yarnnode" ]; then
                             echo "Start Yarn Resource Node  ..."
                 yarn nodemanager
             else
                        echo "not recoginized nodetype "
                 fi
        fi
        fi

fi


######################### segmabi.sh
echo "------------------------------"
echo "-----------Segma BI-----------"
echo "------------Docker------------"
echo "------------------------------"

# unset GIT_DIR
NowPath=`pwd`
DeloyPath=/mnt/repo/segmabi
fix=segma
port=9090
module=segmabi
# branch=beta/5.0

cd $DeloyPath

# git
# git add . -A && git stash
# git branch -a
# git checkout $branch
# git pull

docker stop $module
docker rm $module
docker rmi $fix/$module

mvn clean package -Dmaven.test.skip=true docker:build
docker run -d -m 4048m --restart=on-failure:10 --net="host" -v /mnt/web/:/mnt/web/ --name $module -p $port:$port $fix/$module

exit 0


###############################启动segmabi项目
docker run -d -m 4048m --restart=on-failure:10 --net="host" -v /mnt/web/:/mnt/web/ --privileged=true --name segmabi -p 9090:9090 segma/bi
docker run -d -v /mnt/web/:/mnt/web/ --privileged=true --name bi --add-host hadoopmaster:192.168.40.10 --add-host hadoop001:192.168.40.11 --add-host hadoop002:192.168.40.12 -p 9090:9090 segma/bi
###############################segmabi swagger路径
http://10.75.4.31:9090/swagger-ui.html#/

###############################bi图片服务器启动命令
docker run -d --restart=on-failure:10 --name segmabi-image-nginx -p 9091:80 -v /mnt/web/segmabi/files:/mnt/images segmabi-image-nginx


select column0,column1,column19 from (select row_number() over () as num,column0,column1,column19 from 2018_12_05_02_57_36id237)as t where num between 3 and 13

--add-host master1:192.168.0.148 --add-host master2:192.168.0.147 --add-host master3:192.168.0.146 --add-host node1:192.168.0.151 --add-host node2:192.168.0.150 --add-host node3:192.168.0.149 


<localRepository>/var/www/html/ambari/maven-repo/repository/</localRepository>




############ HDFS排序测试脚本
#!/bin/bash
echo "Terasort测试开始..."
echo "清除测试数据"
hdfs dfs -rm -r -skipTrash /cloud/hdfs-test/terasort-input
hdfs dfs -rm -r -skipTrash /cloud/hdfs-test/terasort-output

#定义需要测试的数据量
datas="1 2 5 10 20 50 100"
for num in $datas ; do
	tput setaf 3
	echo "$num G 数据量测试开始..."
	tput setaf 7
    let "temp = $num * 10000000"
	hadoop jar /usr/hdp/3.1.0.0-78/hadoop-mapreduce/hadoop-mapreduce-examples.jar teragen $temp /cloud/hdfs-test/terasort-input
	hadoop jar /usr/hdp/3.1.0.0-78/hadoop-mapreduce/hadoop-mapreduce-examples.jar terasort /cloud/hdfs-test/terasort-input /cloud/hdfs-test/terasort-output
	
	tput setaf 3
	echo "清除测试数据"
	tput setaf 7
	hdfs dfs -rm -r -skipTrash /cloud/hdfs-test/terasort-input
	hdfs dfs -rm -r -skipTrash /cloud/hdfs-test/terasort-output
	
	tput setaf 3
	echo -e "$num G 数据量测试结束！ \n"
	tput setaf 7
done


#################### TestDFSIO测试脚本
#!/bin/bash
echo "TestDFSIO测试开始..."

#定义需要测试的数据量
datas="1GB 2GB 5GB 10GB 20GB 50GB 100GB"
for num in $datas ; do
	tput setaf 3
	echo "$num 数据量测试开始..."
	tput setaf 7
	hadoop jar /usr/hdp/3.1.0.0-78/hadoop-mapreduce/hadoop-mapreduce-client-jobclient-tests.jar TestDFSIO -write -nrFiles 1 -size $num
	hadoop jar /usr/hdp/3.1.0.0-78/hadoop-mapreduce/hadoop-mapreduce-client-jobclient-tests.jar TestDFSIO -read -nrFiles 1 -size $num

	tput setaf 3
	echo "清除测试数据"
	tput setaf 7
	hadoop jar /usr/hdp/3.1.0.0-78/hadoop-mapreduce/hadoop-mapreduce-client-jobclient-tests.jar TestDFSIO -clean

	tput setaf 3
	echo -e "$num 数据量测试结束！ \n"
	tput setaf 7
done
