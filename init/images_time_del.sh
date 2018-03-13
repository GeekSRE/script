#!/bin/bash
############################
#File Name: images_time_del.sh
#Author: zhaohongye
#Mail: vip@zhaohongye.com
#Created Time:2018-03-08
############################

docker rmi `docker images -q` >> /data/scripts/images_time_del.log

