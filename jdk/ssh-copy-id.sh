#!/bin/bash
############################
#File Name: ssh-copy-id.sh
#Author: zhaohongye
#Mail: vip@zhaohongye.com
#Created Time:2018-03-07
############################
set -e
password="frJfx^ormd8aybpAp2"
ip1=$1
function sshpass()
{
	for ip in $ip1.{1..253};do
		{
		sshpass -p $password ssh-copy-id -o StrictHostKeyChecking=no $ip
		[ $? -eq 0 ] && echo "分配公钥成功：" $ip
		}
	done
}

if [ ! -f "/usr/bin/sshpass" ];then
	yum install -y sshpass
else
	sshpass
fi



