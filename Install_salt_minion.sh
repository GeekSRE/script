#!/usr/bin/bash
#author:zhy
#date:2018-02-08
set -e
timeStamp=`date +%Y%m%d%H%M%S`
##function
#-----installCentOS6-----
function installCentOS6()
{
    yum install -y https://repo.saltstack.com/yum/redhat/salt-repo-latest-2.el6.noarch.rpm
    yum clean expire-cache
    yum install -y salt-minion
    chkconfig salt-minion on 
    mv /etc/salt/minion /etc/salt/minion-bak-$timeStamp
    echo 'master: salt.ops.vcg.com' > /etc/salt/minion
    echo $Ip > /etc/salt/minion_id
    service salt-minion restart && echo "salt_minion installCentOS6 is ok !"
}
#-----installCentOS6-----

#-----installCentOS7-----
function installCentOS7()
{
    yum install -y https://repo.saltstack.com/yum/redhat/salt-repo-latest-2.el7.noarch.rpm >/dev/null 
    yum clean expire-cache >/dev/null 
    yum install -y salt-minion >/dev/null 
    systemctl enable salt-minion.service
    mv /etc/salt/minion /etc/salt/minion-bak-$timeStamp
    echo 'master: salt.ops.vcg.com' > /etc/salt/minion
    echo $Ip > /etc/salt/minion_id
    service salt-minion restart && echo "salt_minion installCentOS7 is ok !"
}
#-----installCentOS7-----

#-----installUbuntu14-----
function installUbuntu14()
{
    wget -O - https://repo.saltstack.com/apt/ubuntu/14.04/amd64/latest/SALTSTACK-GPG-KEY.pub | apt-key add -
    echo 'deb http://repo.saltstack.com/apt/ubuntu/14.04/amd64/latest trusty main' > /etc/apt/sources.list.d/saltstack.list
    apt-get install -y salt-minion
    mv /etc/salt/minion /etc/salt/minion-bak-$timeStamp
    echo 'master: salt.ops.vcg.com' > /etc/salt/minion
    echo $Ip > /etc/salt/minion_id
    update-rc.d salt-minion defaults
    service salt-minion restart && echo "salt_minion installUbuntu14 is ok !"
}
#-----installUbuntu14-----

#-----installUbuntu16-----
function installUbuntu16()
{
    wget -O - https://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest/SALTSTACK-GPG-KEY.pub | apt-key add -
    echo 'deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest xenial main' > /etc/apt/sources.list.d/saltstack.list
    apt-get install -y salt-minion
    mv /etc/salt/minion /etc/salt/minion-bak-$timeStamp
    echo 'master: salt.ops.vcg.com' > /etc/salt/minion
    echo $Ip > /etc/salt/minion_id
    update-rc.d salt-minion defaults
    service salt-minion restart && echo "salt_minion installUbuntu16 is ok !"
}
#-----installUbuntu16-----

#-----basicConfiguration-----
function basicConfiguration()
{
    #check_hosts
    if [ `grep "123.56.0.166 salt.ops.vcg.com" /etc/hosts|wc -l` -eq 0 ]; then
        echo "### salt master host" >> /etc/hosts
        echo "123.56.0.166 salt.ops.vcg.com" >> /etc/hosts
    ##check_minion_configure
    elif [ `grep 'master: salt.ops.vcg.com' /etc/salt/minion|wc -l` -eq 0 ]; then
        mv /etc/salt/minion /etc/salt/minion-bak-$timeStamp
        echo 'master: salt.ops.vcg.com' > /etc/salt/minion
    ##check_minion_id
    elif [ ! -f "/etc/salt/minion_id" ]; then
        echo '/etc/salt/minion_id 文件不存在'
        if [ `grep $Ip /etc/salt/minion_id|wc -l` -eq 0 ]; then
            echo $Ip > /etc/salt/minion_id && echo 'minion_id is set ok'
        fi
    fi
}
#-----basicConfiguration-----

#-----getIP-----
function getIP()
{
    ipUnm=`ip addr|grep 'scope global'|wc -l`
    if [ $ipUnm -ge 2 ];then
        Ip=`ip addr|grep 'scope global'|awk '{print $2}'|awk -F'/' '{print $1}'|tr '\n' ' '|awk '{print $1"-"$2}'`
        echo '本机IP地址： ' $Ip
    elif [ $ipUnm -eq 1 ]; then
        Ip=`ip addr|grep 'scope global'|awk '{print $2}'|awk -F'/' '{print $1}'`
        echo '本机IP地址： ' $Ip
    else
        echo 'get ip error !'
        exit 1
    fi
}
#-----getIP-----

#-----getOS-----
function getOS()
{
    if [ `uname -a|grep Ubuntu|wc -l` -eq 1 ]; then
        if [ `cat /etc/os-release |grep VERSION_ID|grep '14.04'|wc -l` -eq 1 ]; then
            echo '系统版本为： Ubuntu 14'
            installUbuntu14
        elif [ `cat /etc/os-release |grep VERSION_ID|grep '16.04'|wc -l` -eq 1 ]; then
            echo '系统版本为： Ubuntu 16'
            installUbuntu16 
        else
            echo 'os version is not support ! '
        fi
    elif [ `uname -a|grep el6|wc -l` -eq 1 ]; then
        echo '系统版本为： CentOS 6 '
        installCentOS6
    elif [ `uname -a|grep el7|wc -l` -eq 1 ]; then
        echo '系统版本为： CentOS 7 '
        installCentOS7
    else
        echo 'os version is not support ! '
    fi
}
#-----getOS-----

#-----restartSalt-----
function restartSalt()
{
    for i in `ps -ef |grep salt-minion |grep -v grep|awk '{print $2}'`
    do
        kill -9 $i
    done
    service salt-minion start 
}
#-----restartSalt-----


#-----confirmSalt-----
function confirmSalt()
{
    if [ `ps -ef |grep salt-minion|grep -v grep|wc -l` -eq 0 ];then
        if [ ! -d "/etc/salt/" ];then
            echo "salt-minion is not installed"  
            getIP
            getOS
            basicConfiguration
            restartSalt && echo 'salt_minion is install ok '
        else
            rm -f /etc/salt/pki/minion/minion_master.pub
            basicConfiguration
            restartSalt && echo 'salt_minion is configure ok '
        fi
    else
        basicConfiguration
        restartSalt && echo 'salt_minion is configure ok '
    fi
}
#-----confirmSalt-----

confirmSalt

#
#if [[ `service salt-minion status |grep 'No module named certifi'|wc -l` -eq 1 ]]; then
#    curl "http://sh.ops.ren/software/pip/get-pip.py" | python
#    pip install certifi
#    service salt-minion restart
#    exit 0
#fi
#
#Error unpacking rpm package python-urllib3-1.10.2-3.el7.noarch
#curl "http://sh.ops.ren/software/pip/get-pip.py" | python
#pip uninstall urllib3 -y

