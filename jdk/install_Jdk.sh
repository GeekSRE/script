#!/bin/bash
############################
#File Name: install_Jdk.sh
#Author: zhaohongye
#Mail: vip@zhaohongye.com
#Created Time:2018-03-04
############################
set -e
shUrl="http://sh.ops.ren"
install_Dir="/data/vcg/"
yum install wget -y 

mkdir -p $install_Dir
cd $install_Dir
wget $SHURL/software/jdk/jdk-8u161-linux-x64.tar.gz
tar zxf jdk-8u161-linux-x64.tar.gz

cat > /etc/profile <<EOF
##jdk
export JAVA_HOME=/data/vcg/jdk1.8.0_161
export CLASSPATH=.:$JAVA_HOME/jar/lib/rt.jar:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export PATH=$JAVA_HOME/bin:$PATH
EOF

java --version
