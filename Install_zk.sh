#!/bin/bash
#服务zk部署脚本
#author:zhy
#date:20171218
#version:0.1
########################################
set -e

SHURL="http://sh.ops.ren"
HOSTADD=`ip addr|egrep "192|172"|head -n 1|awk -F"/" '{print $1}'|awk '{print $2}'`

read -p " please chose zookeeper_install_type : ( cluster or one ) " instll_type
read -p " please input youe app install Dir : ( ) " Install_Dir

function one_install(){
cd $Install_Dir
wget $SHURL/software/zookeeper/zookeeper-3.4.10.tar.gz
tar zxf zookeeper-3.4.10.tar.gz

cat > $Install_Dir/zookeeper-3.4.10/conf/zoo.cfg <<EOF
tickTime=3000
initLimit=10
syncLimit=5
dataDir=/data/databases/zookeeper/data
dataLogDir=/data/databases/zookeeper/log
clientPort=2181
minSessionTimeout=30000
maxSessionTimeout=60000
EOF

mkdir -p /data/databases/zookeeper/data
mkdir -p /data/databases/zookeeper/log
echo '1' >  /data/databases/zookeeper/data/myid
if [[ `cat /etc/profile|grep ZOOKEEPER|wc -l` -eq 0 ]];then
    echo "export ZOOKEEPER=${Install_Dir}/zookeeper-3.4.10" >> /etc/profile
    echo "export PATH=\$PATH:\$ZOOKEEPER/bin" >> /etc/profile
    source /etc/profile
    echo "add zk profile_env is successed"
else
    echo "add zk profile_env is failed"
fi
sh ${Install_Dir}/zookeeper-3.4.10/bin/zkServer.sh start
sleep 5
sh ${Install_Dir}/zookeeper-3.4.10/bin/zkServer.sh status
}



function cluster_instll() {
read -p " please input zk_slave1_IP : " zk_slave1_IP
read -p " please input zk_slave2_IP : " zk_slave2_IP
read -p " please input zk_slave3_IP : " zk_slave3_IP

cd $Install_Dir
wget $SHURL/software/zookeeper/zookeeper-3.4.10.tar.gz
tar zxf zookeeper-3.4.10.tar.gz

cat > $Install_Dir/zookeeper-3.4.10/conf/zoo.cfg <<EOF
tickTime=3000
initLimit=10
syncLimit=5
dataDir=/data/databases/zookeeper/data
dataLogDir=/data/databases/zookeeper/log
clientPort=2181
minSessionTimeout=30000
maxSessionTimeout=60000
server.1=slave1:2888:3888
server.2=slave2:2888:3888
server.3=slave3:2888:3888
EOF

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
    echo "add zk_slave DNS is successed"
 else
    echo "add zk_slave DNS is failed"
fi
#profile
if [[ `cat /etc/profile|grep ZOOKEEPER|wc -l` -eq 0 ]];then
    echo "export ZOOKEEPER=${Install_Dir}/zookeeper-3.4.10" >> /etc/profile
    echo "export PATH=\$PATH:\$ZOOKEEPER/bin" >> /etc/profile
    source /etc/profile
    echo "add zk profile_env is successed"
else
    echo "add zk profile_env is failed"
fi
sh ${Install_Dir}/zookeeper-3.4.10/bin/zkServer.sh start
sleep 5
sh ${Install_Dir}/zookeeper-3.4.10/bin/zkServer.sh status
}

case $instll_type in
    cluster)
    cluster_instll
        ;;
    one)
    one_install
        ;;
esac



