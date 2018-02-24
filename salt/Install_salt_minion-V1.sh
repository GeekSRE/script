#!/usr/bin/bash
#author:zhy
#date:2018-02-07
set -e
##set variable
Version=`rpm -qa|grep kernel|head -n 1|awk -F'el' '{print $3}'|awk -F'.x' '{print $1}'`
Salt_DNS=`grep "123.56.0.166 salt.ops.vcg.com" /etc/hosts|wc -l`
Salt_STATUS=`ps -ef |grep salt-minion|grep -v grep|wc -l`
ip_num=`ip addr|grep 'scope global'|wc -l`
if [ $ip_num -eq 2 ];then
    Ip=`ip addr|grep 'scope global'|awk '{print $2}'|awk -F'/' '{print $1}'|tr '\n' ' '|awk '{print $1"-"$2}'`
    echo $Ip
elif [ $ip_num -eq 1 ]; then
    Ip=`ip addr|grep 'scope global'|awk '{print $2}'|awk -F'/' '{print $1}'`
    echo $Ip
else
    echo 'get ip error !'
    exit 1
fi
##echo variable 
echo ''
echo "-----------------------------------"
echo ''
echo "Ip is " $Ip
echo ''
echo "-----------------------------------"
echo ''
echo "This host_OS_Version is " $Version
echo ''
echo "-----------------------------------"
echo ''
echo "ps -ef |grep salt-minion |wc -l  is " $Salt_STATUS
echo ''
echo "-----------------------------------"
##/etc/hosts
if [ $Salt_DNS -eq 1 ];then
    echo "salt-master dns (#/etc/hosts#) is ok."
else
    echo "### salt master host" >> /etc/hosts
    echo "123.56.0.166 salt.ops.vcg.com" >> /etc/hosts
    echo "salt-master dns (#/etc/hosts#) is ok."
fi

#-----function-----
function salt_config()
{
##set variable
Salt_minion_id=`cat /etc/salt/minion |grep -v '^#'|grep -v '^$' |grep 'id: '$Ip'' |wc -l`
Salt_minion_dns=`cat /etc/salt/minion |grep -v '^#'|grep -v '^$' |grep 'master: salt.ops.vcg.com' |wc -l`
rm -f /etc/salt/pki/minion/minion_master.pub
for i in `ps -ef |grep salt-minion |grep -v grep|awk '{print $2}'`
    do
kill -9 $i
    done
if [ $Salt_minion_dns -eq 0 ];then
    cp /etc/salt/minion /etc/salt/minion-bak
    echo 'master: salt.ops.vcg.com' > /etc/salt/minion 
    echo "salt_minion_dns set ok"
    service salt-minion restart && echo "salt_minion restart ok"
fi
if [ $Salt_minion_id -eq 0 ];then
    echo $Ip > /etc/salt/minion_id  && echo "salt_minion_id set ok"
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
    exit 0
    else
        if [[ $Version == "6" ]];then
            yum install -y https://repo.saltstack.com/yum/redhat/salt-repo-latest-2.el6.noarch.rpm >/dev/null 
            yum clean expire-cache >/dev/null 
            yum install -y salt-minion >/dev/null 
            chkconfig salt-minion on 
            sed '/master: salt/a\master: salt.ops.vcg.com' -i /etc/salt/minion
            echo $Ip > /etc/salt/minion_id
            service salt-minion restart && echo "salt_minion restart ok"
        elif [[ $Version == "7" ]];then
            yum install -y https://repo.saltstack.com/yum/redhat/salt-repo-latest-2.el7.noarch.rpm >/dev/null 
            yum clean expire-cache >/dev/null 
            yum install -y salt-minion >/dev/null 
            systemctl enable salt-minion.service
            sed '/master: salt/a\master: salt.ops.vcg.com' -i /etc/salt/minion
            echo $Ip > /etc/salt/minion_id
            service salt-minion restart && echo "salt_minion restart ok"
        else
            echo 'os version is not support ! ' 
        fi
fi

if [[ `service salt-minion status |grep 'No module named certifi'|wc -l` -eq 1 ]]; then
    curl "http://sh.ops.ren/software/pip/get-pip.py" | python
    pip install certifi
    service salt-minion restart
fi

