#!/bin/bash
#Jenkins构建脚本
#author:zhy
#date:20171226
########################################
set -e
##ENV
Harbor_U="admin"
Harbor_P="Harbor12345"
Harbor_Url="dockreg.biyao.com"
Work_Dir='/home/docker-build'
Package_Dir="/data/code"

##最新的包
NewPackage=`find $Package_Dir -name "$1*.tar.gz"  -printf "%AD %AT %f\n"|sort|tail -1|awk '{print $3}'`
Image_name=`echo $1 |awk -F'_' '{print $1}'`
Image_Version=`ls $Package_Dir/$NewPackage|awk -F'm_' '{print $2}'|awk -F '.tar.gz' '{print $1}'`

cp $Package_Dir/$NewPackage $Work_Dir

cat > $Work_Dir/Dockerfile <<EOF
FROM  dockreg.biyao.com/comm/tomcat8.0.9:centos6.5
MAINTAINER   zhy
RUN rm -rf /usr/local/biyao/apache-tomcat-8.0.9/webapps/*
ADD $NewPackage /usr/local/biyao/apache-tomcat-8.0.9/webapps/
EXPOSE 8080
EOF

cd $Work_Dir
docker build -t $Harbor_Url/project/$Image_name:$Image_Version .

docker login $Harbor_Url -u $Harbor_U -p $Harbor_P

docker push dockreg.biyao.com/project/$Image_name:$Image_Version

[ $? -eq 0 ] && echo 'docker push ok ! '

rm -f $Work_Dir/$NewPackage
mv Dockerfile Dockerfile-$Image_name:$Image_Version