#!/bin/bash
#Jenkins构建脚本
#author:zhy
#date:20171226
########################################
set -e

New_Uer='biyao'
Use_Pass='123456'

id $New_Uer
if [ $? -eq 0 ];then
	echo '$New_Uer 已经存在 ! '
else
	useradd $New_Uer
	echo '$Use_Pass' | passwd –stdin $New_Uer
	