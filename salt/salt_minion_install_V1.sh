#!/usr/bin/bash

#author:zhy
#date:2017-11-30

set -e
Version=`cat /etc/redhat-release|awk -F"release" '{print $2}'|awk '{print $1}'|awk -F"." '{print $1}'`
Salt_DNS=`grep "192.168.96.29 salt.ops.biyao.com" /etc/hosts|wc -l`
Salt_STATUS=`ps -ef |grep salt-minion|grep -v grep|wc -l`
Salt_minion_dns=`cat /etc/salt/minion |grep -v '^#'|grep -v '^$' |grep 'master: salt.ops.biyao.com' |wc -l`
Ip=`ip addr|egrep "192|172"|head -n 1|awk -F"/" '{print $1}'|awk '{print $2}'`
Salt_minion_id=`cat /etc/salt/minion |grep -v '^#'|grep -v '^$' |grep 'id: '$Ip'' |wc -l`

echo "Version is " $Version
echo "Salt_DNS is " $Salt_DNS
echo "Salt_STATUS is " $Salt_STATUS
echo "Salt_minion_dns is " $Salt_minion_dns
echo "Ip is " $Ip

##/etc/hosts
if [ $Salt_DNS -eq 1 ];then
    echo "salt-master dns (#/etc/hosts#) is ok."
else
    echo "### salt master host" >> /etc/hosts
    echo "192.168.96.29 salt.ops.biyao.com" >> /etc/hosts
    echo "salt-master dns (#/etc/hosts#) is ok."
fi
if [ $Salt_minion_dns -eq 0 ];then
    sed '/master: salt/a\master: salt.ops.biyao.com' -i /etc/salt/minion 
    echo "salt_minion_dns set ok"
fi

if [ $Salt_STATUS -ge 1 ];then
    echo "salt is install ok."
    else
        if [[ $Version == "6" ]];then
            yum install -y https://repo.saltstack.com/yum/redhat/salt-repo-latest-2.el6.noarch.rpm
            yum clean expire-cache
            yum install -y salt-minion 
            chkconfig salt-minion on
            sed '/master: salt/a\master: salt.ops.biyao.com' -i /etc/salt/minion
            echo 'id: '$Ip'' >> /etc/salt/minion
        else
            yum install -y https://repo.saltstack.com/yum/redhat/salt-repo-latest-2.el7.noarch.rpm 
            yum clean expire-cache
            yum install -y salt-minion
            systemctl enable salt-minion.service
            sed '/master: salt/a\master: salt.ops.biyao.com' -i /etc/salt/minion
            echo 'id: '$Ip'' >> /etc/salt/minion
        fi
fi
if [ $Salt_minion_id -eq 0 ];then
    echo 'id: '$Ip'' >> /etc/salt/minion  && echo "salt_minion_id set ok"
fi

service salt-minion restart && echo "salt_minion restart ok"




