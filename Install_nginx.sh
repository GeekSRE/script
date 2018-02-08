#!/bin/bash
#Nginx安装脚本、分为源码和yum安装
#author:zhy
#date:20180109
########################################
set -e

APPDIR="/usr/local"
OS_Version=`cat /etc/redhat-release|awk -F"release" '{print $2}'|awk '{print $1}'|awk -F"." '{print $1}'`


def Yum_Install(){
if [[ $OS_Version == "7" ]]; then
	wget http://sh.ops.ren/software/nginx/nginx-release-centos-7-0.el7.ngx.noarch.rpm
	rpm -ivh nginx-release-centos-7-0.el7.ngx.noarch.rpm
	yum install nginx -y
	systemctl enable nginx
	systemctl start nginx
elif [[ $OS_Version == "6" ]]; then
	wget http://sh.ops.ren/software/nginx/nginx-release-centos-6-0.el6.ngx.noarch.rpm
	rpm -ivh http://sh.ops.ren/software/nginx/nginx-release-centos-6-0.el6.ngx.noarch.rpm
	yum install nginx -y
	chkconfig -add nginx
	chkconfig nginx on
	service nginx start
else
	echo "OS_Version is not support ! "
}


def Source_Install(){
yum install -y gcc gcc-c++
#down package
cd $APPDIR
wget http://sh.ops.ren/software/nginx/nginx-1.12.2.tar.gz
wget http://sh.ops.ren/software/nginx/openssl-1.0.1c.tar.gz
wget http://sh.ops.ren/software/nginx/pcre-8.39.tar.gz
wget http://sh.ops.ren/software/nginx/zlib-1.2.8.tar.gz

#unzip
cd $APPDIR
tar zxf pcre-8.39.tar.gz
tar zxf zlib-1.2.8.tar.gz
tar zxf openssl-1.0.1c.tar.gz
tar zxf nginx-1.12.2.tar.gz

#install
cd $APPDIR/pcre-8.39
./configure && make && make install
[ $? -eq 0 ] && echo "#########  one step : install pcre ok  #########"
cd $APPDIR/zlib-1.2.8
./configure && make && make install
[ $? -eq 0 ] && echo "#########  two step : install zlib ok  #########"
 cd $APPDIR/openssl-1.0.1c
./config && make && make install
[ $? -eq 0 ] && echo "#########  three step : install openssl ok  #########"
cd $APPDIR/nginx-1.10.1
./configure --sbin-path=/usr/local/nginx/nginx \
--conf-path=$APPDIR/nginx/nginx.conf \
--pid-path=$APPDIR/nginx/nginx.pid \
--with-http_stub_status_module \
--with-http_ssl_module \
--with-pcre=$APPDIR/pcre-8.39 \
--with-zlib=$APPDIR/zlib-1.2.8 \
--with-openssl=$APPDIR/openssl-1.0.1c
make && make install
[ $? -eq 0 ] && echo "################## install nginx ok ##################"
}


read -p " Install Ngx type : (source or yum) : " type
case $type in
    source)
        Source_Install
    ;;
    yum)
	Yum_Install
    ;;
esac
