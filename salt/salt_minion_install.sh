#!/usr/bin/bash

#author:zhy
#date:2017-12-01

set -e

##set variable
Version=`cat /etc/redhat-release|awk -F"release" '{print $2}'|awk '{print $1}'|awk -F"." '{print $1}'`
Salt_DNS=`grep "192.168.99.9 salt.ops.biyao.com" /etc/hosts|wc -l`
Salt_STATUS=`ps -ef |grep salt-minion|grep -v grep|wc -l`
Ip=`ip addr|egrep "192|172"|head -n 1|awk -F"/" '{print $1}'|awk '{print $2}'`

##echo variable 
echo ''
echo ''
echo ''
echo "-----------------------------------"
echo "Ip is " $Ip
echo ''
echo "-----------------------------------"
echo "This host_OS_Version is " $Version
echo ''
echo "-----------------------------------"
echo "ps -ef |grep salt-minion |wc -l  is " $Salt_STATUS
echo ''
echo "-----------------------------------"

##/etc/hosts
if [ $Salt_DNS -eq 1 ];then
    echo "salt-master dns (#/etc/hosts#) is ok."
else
    echo "### salt master host" >> /etc/hosts
    echo "192.168.99.9 salt.ops.biyao.com" >> /etc/hosts
    echo "salt-master dns (#/etc/hosts#) is ok."
fi

#-----function-----
function salt_config()
{
##set variable
Salt_minion_id=`cat /etc/salt/minion |grep -v '^#'|grep -v '^$' |grep 'id: '$Ip'' |wc -l`
Salt_minion_dns=`cat /etc/salt/minion |grep -v '^#'|grep -v '^$' |grep 'master: salt.ops.biyao.com' |wc -l`

if [ $Salt_minion_dns -eq 0 ];then
    sed '/master: salt/a\master: salt.ops.biyao.com' -i /etc/salt/minion 
    echo "salt_minion_dns set ok"
    service salt-minion restart && echo "salt_minion restart ok"
fi
if [ $Salt_minion_id -eq 0 ];then
    echo 'id: '$Ip'' >> /etc/salt/minion  && echo "salt_minion_id set ok"
    service salt-minion restart && echo "salt_minion restart ok"
fi
}
#-----function-----

##config salt_installed or not 
if [ ! -d "/etc/salt/" ];then
    echo "salt is not installed"  
    else
        salt_config
fi  
##config OS_Version
if [ $Salt_STATUS -ge 1 ];then
    echo "salt-minion is running ! ! !"
    else
        if [[ $Version == "6" ]];then
           # yum install -y https://repo.saltstack.com/yum/redhat/salt-repo-latest-2.el6.noarch.rpm
            yum install -y http://192.168.99.9/software/salt/salt-repo-latest-2.el6.noarch.rpm
            yum clean expire-cache
            yum install -y salt-minion 
            chkconfig salt-minion on
            sed '/master: salt/a\master: salt.ops.biyao.com' -i /etc/salt/minion
            echo 'id: '$Ip'' >> /etc/salt/minion
            service salt-minion restart && echo "salt_minion restart ok"
        else
            #yum install -y https://repo.saltstack.com/yum/redhat/salt-repo-latest-2.el7.noarch.rpm 
            yum install -y http://192.168.99.9/software/salt/salt-repo-latest-2.el7.noarch.rpm
            yum clean expire-cache
            yum install -y salt-minion
            systemctl enable salt-minion.service
            sed '/master: salt/a\master: salt.ops.biyao.com' -i /etc/salt/minion
            echo 'id: '$Ip'' >> /etc/salt/minion
            service salt-minion restart && echo "salt_minion restart ok"
        fi
fi


