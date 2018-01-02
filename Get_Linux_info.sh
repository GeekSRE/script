#!/usr/bin/bash
set -e
cpu_num=`cat /proc/cpuinfo | grep "physical id" | sort -u | wc -l`
cpu_info=`cat /proc/cpuinfo |grep "model name" | sort -u`
mem_total=`free -ml |grep Mem | awk '{print $2}'`
### CPU个数
echo "CPU个数是：" $cpu_num

### CPU规格
echo "CPU规格"
echo $cpu_info

### mem
echo "内存共计（M）: "  $mem_total

echo "fdisk -l| grep Disk |grep GB"
fdisk -l| grep Disk |grep GB

echo "df -Th"

df -Th


