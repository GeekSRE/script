#!/bin/bash
#subnet=`route -n|grep "UG" |awk '{print $2}'|sed 's/..$//g'`

for i in "192.168.99"  "192.168.96"  "192.168.97" "172.17.12" ; do
	for ip in $i.{1..253};do
		{
		ping -c1 $ip >/dev/null 2>&1
		}&
	done
done

#依次查找arp记录.
running_vms=`virsh list |grep running`
echo -ne "共有`echo "$running_vms"|wc -l`个虚拟机在运行.            IP地址：\n"
for i in `echo "$running_vms" | awk '{ print $2 }'`;do
mac=`virsh dumpxml $i |grep "mac address"|sed "s/.*'\(.*\)'.*/\1/g"`
ip=`arp -ne |grep "$mac" |awk '{printf $1}'`
printf "%-30s %-30s\n" $i $ip
done

