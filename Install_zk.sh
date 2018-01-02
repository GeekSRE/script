#!/bin/bash
#服务zk部署脚本
#author:zhy
#date:20171218
#version:0.1
########################################
set -e
Sh_DNS=`grep "192.168.99.9 sh.ops.biyao.com" /etc/hosts|wc -l`
SHURL="http://sh.ops.biyao.com"
Install_Dir="/usr/local/biyao"

###set sh.ops.biyao.com
if [ $Sh_DNS -eq 0 ];then
    echo "192.168.99.9 sh.ops.biyao.com" >> /etc/hosts
    echo "sh.ops.biyao.com dns is ok."
else
    echo "sh.ops.biyao.com dns is ok."
fi
##install
mkdir -p $Install_Dir/apache-rocketmq-4.2.0
cd $Install_Dir/apache-rocketmq-4.2.0
wget $SHURL/software/rocketmq/rocketmq-all-4.2.0-bin-release.zip

unzip rocketmq-all-4.2.0-source-release.zip
mv rocketmq-all-4.2.0 apache-rocketmq-4.2.0
HOSTADD=`ip addr|egrep "192|172"|head -n 1|awk -F"/" '{print $1}'|awk '{print $2}'`





cd $Install_Dir
wget $SHURL/software/zookeeper/zookeeper-3.4.10.tar.gz
tar zxf zookeeper-3.4.10.tar.gz
cd $Install_Dir/zookeeper-3.4.10/conf
wget $SHURL/software/zookeeper/zoo.cfg
mkdir -p /data/databases/zookeeper/data
mkdir -p /data/databases/zookeeper/log
if [[ $HOSTADD == $zk_slave1_IP ]];then
	echo '1' >  /data/databases/zookeeper/data/myid
elif [[ $HOSTADD == $zk_slave2_IP ]];then
	echo '2' >  /data/databases/zookeeper/data/myid
elif [[ $HOSTADD == $zk_slave3_IP ]];then
	echo '3' >  /data/databases/zookeeper/data/myid
fi 
#dns
if [[ `cat /etc/hosts|grep zk_slave1|wc -l` -eq 0 ]];then
    echo "$zk_slave1_IP zk_slave1" >> /etc/hosts
    echo "$zk_slave2_IP zk_slave2" >> /etc/hosts
    echo "$zk_slave3_IP zk_slave3" >> /etc/hosts
    echo "add zk_slave dns is successed"
 else
 	echo "add zk_slave is failed"
fi
#profile
if [[ `cat /etc/profile|grep ZOOKEEPER|wc -l` -eq 0 ]];then
	echo "export ZOOKEEPER=/usr/local/biyao/zookeeper-3.4.10" >> /etc/profile
    echo "export PATH=\$PATH:\$ZOOKEEPER/bin" >> /etc/profile
    source /etc/profile
    echo "add zk profile_env is successed"
else
	echo "add zk profile_env is failed"
fi


