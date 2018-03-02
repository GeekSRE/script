#!/bin/bash
############################
#File Name: init_vcg.sh
#Author: zhaohongye
#Mail: vip@zhaohongye.com
#Created Time:2018-03-02 
############################
set -e
ip=`ip addr|egrep "192|172"|head -n 1|awk -F"/" '{print $1}'|awk '{print $2}'|sed 's/\./-/g'`
backDir='/data/back'

function mkdirDir()
{
   mkdir -p /data/vcg
   mkdir -p /data/back
   mkdir -p /data/ops
}

function setmotd()
{
    cat > /etc/motd <<EOF

    Welcome to VCG !
    视觉无处不在  视觉服务中国

    程序目录：/data/vcg/
    脚本目录：/data/scripts/
    备份目录：/data/back/

EOF
}

function setRepo()
{
    if [[ `cat /etc/yum.repos.d/CentOS-Base.repo |grep ali|wc -l` -eq 0  ]];then
        cd /etc/yum.repos.d/ && tar zcvf repo_back_`date +%Y%m%d%H%M%S`.tar.gz *  
        mv repo_back* /data/back/ && rm -f *
        if [[ `uname -a|grep el6|wc -l` -eq 1 ]]; then
            curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo
        elif [[ `uname -a|grep el7|wc -l` -eq 1 ]]; then 
            curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
        fi
        yum clean all && yum makecache
        echo "set ali_repo is ok !"
    fi
}

function setHostname()
{
    if [ `hostname|grep localhost|wc -l` -eq 1 ];then
        sysctl kernel.hostname=$ip
    fi
    echo "hostname is `hostname` !"
}

function setSelinux()
{
    if [[ `getenforce` == "Enforcing" ]];then
        setenforce 0
        sed -i "s/'SELINUX=enforcing'/'SELINUX=disabled'/" /etc/selinux/config
        echo 'selinux 已关闭，请重启!'
    else
        echo 'selinux is ok !'
    fi
}

function setTimezone()
{
    if [[ `md5sum /usr/share/zoneinfo/Asia/Shanghai |awk '{print $1}'` == `md5sum /etc/localtime |awk '{print $1}'` ]]; then
        echo "时区为：上海时区"
    else 
        cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    fi
}

function getOS()
{
    if [ `uname -a|grep Ubuntu|wc -l` -eq 1 ]; then
        if [ `cat /etc/os-release |grep VERSION_ID|grep '14.04'|wc -l` -eq 1 ]; then
            echo '系统版本为： Ubuntu 14'
        elif [ `cat /etc/os-release |grep VERSION_ID|grep '16.04'|wc -l` -eq 1 ]; then
            echo '系统版本为： Ubuntu 16' 
        else
            echo 'os version is not support ! '
        fi
    elif [ `uname -a|grep el6|wc -l` -eq 1 ]; then
        echo '系统版本为： CentOS 6 '
        setRepo
        mkdirDir
        setSelinux
        setHostname
        setTimezone
        setmotd
    elif [ `uname -a|grep el7|wc -l` -eq 1 ]; then
        echo '系统版本为： CentOS 7 '
        setRepo
        mkdirDir
        setSelinux
        setHostname
        setTimezone
        setmotd
    else
        echo 'os version is not support ! '
    fi
}
getOS