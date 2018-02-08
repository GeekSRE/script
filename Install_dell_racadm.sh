#!/bin/bash
#dell 硬件管理软件安装脚本
#author:zhy
#date:20180109
########################################
set -e
##ENV
OS_Version=`cat /etc/redhat-release|awk -F"release" '{print $2}'|awk '{print $1}'|awk -F"." '{print $1}'`
if [[ $OS_Version == "7" ]]; then
        yum install wget -y
        mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
        wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo
        wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo

elif [[ $OS_Version == "6" ]]; then
        yum install wget -y
        mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
        wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS6-Base-163.repo
        wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo
fi
yum install -y openwsman-server  openwsman-client  sblim-sfcb  sblim-sfcc  libwsman1  libcmpiCppImpl0
yum install -y net-snmp-utils
yum install -y smbios-utils-bin smbios-utils-bin
cd /tmp
wget http://sh.ops.ren/software/dell/OM-MgmtStat-Dell-Web-LX-8.5.0-2372_A00.tar.gz
tar zxf OM-MgmtStat-Dell-Web-LX-8.5.0-2372_A00.tar.gz
if [[ $OS_Version == "7" ]]; then
        cd linux/rac/RHEL7/x86_64/
        rpm -ivh srvadmin*
elif [[ $OS_Version == "6" ]]; then
        cd linux/rac/RHEL6/x86_64/
        rpm -ivh srvadmin*
fi
ln -s /opt/dell/srvadmin/sbin/racadm  /usr/sbin/racadm
racadm getsysinfo
