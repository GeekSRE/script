#!/bin/sh
#############################
#zhaohongye-2017-0712
#优易ODC使用
#zabbix_agent install 
##############################

APPDIR="/usr/local"
zbDIR='/usr/local/zabbix'
APP='zabbix-3.0.5.tar.gz'
Package='http://sh.ops.youedata.com/package/zabbix'
if [ ! -d $zbDIR ]; then
yum install gcc*  make wget -y
rpm -e `rpm -qa |grep zabbix`
cd $APPDIR
wget $Package/$APP
userdel zabbix
useradd -r -s /sbin/nologin zabbix
tar zxf $APP
cd $APPDIR/zabbix-3.0.5
./configure --prefix=/usr/local/zabbix --enable-agent
make install
rm -rf $APPDIR/zabbix-3.0.5*
rm -f $zbDIR/etc/zabbix_agentd.conf
cd $zbDIR/etc/
wget $Package/zabbix_agentd.conf
cd  $zbDIR/sbin/
./zabbix_agentd
chmod +x /etc/rc.d/rc.local
echo 'cd /usr/local/zabbix/sbin/ ./zabbix_agentd' >> /etc/rc.local
netstat -ntl |grep 10050
lsof -i:10050
ps -ef |grep zabbix
fi