#!/bin/bash
#必要运维主机初始化脚本
#author:zhy
#date:20171215
#version:0.1
########################################
set -e

Xpy_vm=$1
XTYPE=$2
INSTALL=$3
###var set
HOSTADD=`ip addr|egrep "192|172"|head -n 1|awk -F"/" '{print $1}'|awk '{print $2}'|awk -F"." '{print $3"."$4}'|sed 's/\./-/g'`
VERSION=`cat /etc/redhat-release|awk -F"release" '{print $2}'|awk '{print $1}'|awk -F"." '{print $1}'`
SETHOSTNAME=`hostname|grep localhost|wc -l`
SETDNS1=`cat /etc/resolv.conf |grep '202.106.196.115' | wc -l `
SETDNS2=`cat /etc/resolv.conf |grep '233.6.6.6' | wc -l `
YDATE="alias ybak='date +%Y%m%d%H%M%S'"
NS1="nameserver 202.106.196.115"
NS2="nameserver 233.6.6.6"
HOSTNAME="$Xpy_vm-$XTYPE-$HOSTADD"
Sh_DNS=`grep "192.168.99.9 sh.ops.biyao.com" /etc/hosts|wc -l`
SHURL="http://sh.ops.biyao.com"
SELINUX=`getenforce`
mirrors7_163="/etc/yum.repos.d/CentOS7-Base-163.repo"
mirrors6_163="/etc/yum.repos.d/CentOS6-Base-163.repo"

###set selinux
if [[ $SELINUX == "Enforcing" ]];then
    setenforce 0
    sed -i "s/'SELINUX=enforcing'/'SELINUX=disabled'/" /etc/selinux/config
    echo 'selinux is change ok !'
else
    echo 'selinux is ok !'
fi

###set sh.ops.biyao.com
if [ $Sh_DNS -eq 0 ];then
    echo "192.168.99.9 sh.ops.biyao.com" >> /etc/hosts
    echo "sh.ops.biyao.com dns is ok."
else
    echo "sh.ops.biyao.com dns is ok."

fi

###export
if [[ $SETDNS1 -eq 0 ]];then
    echo 'config liantong DNS !'
    echo $NS1 >> /etc/resolv.conf
else
    echo 'liantong DNS is OK ！'
fi

if [[ $SETDNS1 -eq 0 ]];then
    echo 'config Ali DNS !'
    echo $NS2 >> /etc/resolv.conf
else
    echo 'Ali DNS is OK ！'
fi

echo $YDATE >> /root/.bash_profile
source /root/.bash_profile
###set hostname
if [ $SETHOSTNAME -eq 1 ];then
    sysctl kernel.hostname=$HOSTNAME
    echo "config hostname is success , hostname : $HOSTNAME !"
else
    echo "hostname is $HOSTNAME !"
fi
echo $VERSION
###初始化基础配置
if [[ $VERSION == "7" ]];then
    # os version 7
    echo "config timezone is Shanghai"
    timedatectl set-timezone Asia/Shanghai

    ###set yum mirrors
    if [[ ! -f $mirrors7_163 ]];then
        rm -f /etc/yum.repos.d/CentOS-Base.repo
        curl -o /etc/yum.repos.d/CentOS7-Base-163.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo 
        curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
        yum clean all 1>/dev/null
        echo 'yum clean all is ok '
        yum makecache 1>/dev/null
        echo 'yum makecache is ok '
        echo 'config yum mirrors is OK！'
    else
        echo 'yum mirrors is OK！'
    fi
else
    # os version 6
    
    rm -f /etc/localtime
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    ###set yum mirrors
    if [[ ! -f $mirrors6_163 ]];then
        rm -f /etc/yum.repos.d/CentOS-Base.repo
        #mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
        curl -o /etc/yum.repos.d/CentOS6-Base-163.repo http://mirrors.163.com/.help/CentOS6-Base-163.repo
        curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo
        yum clean all 1>/dev/null
        echo 'yum clean all is ok '
        yum makecache 1>/dev/null
        echo 'yum makecache is ok '
        echo 'config yum mirrors is OK！'
    else
        echo 'yum mirrors is OK！'
    fi
fi

###add sshkey
echo 'add sshkey will going !'
curl -o /tmp/odc.pub $SHURL/script/ssh_odc.pub
mkdir -p /root/.ssh/
cat /tmp/odc.pub >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
echo 'add sshkey is ok !'

######function

pip_install(){
    curl -L $SHURL/software/pip/get-pip.py | python
}

stack_install() {
    curl -L $SHURL/script/salt/salt_minion_install.sh | bash  
    }

if [[ $INSTALL == "all" ]];then
    stack_install

elif [[ $INSTALL == "salt" ]];then
    stack_install
else
    echo "Install name"
    exit 1
fi
