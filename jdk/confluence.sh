#!/bin/bash
############################
#File Name: install_confluence.sh
#Author: zhaohongye
#Mail: vip@zhaohongye.com
#Created Time:2018-03-05
############################
set -e
install_Dir="/data/vcg/"

useradd -create-home --comment "Account for running Confluence" --shell /bin/bash confluence
cd $install_Dir
unzip atlassian-confluence-6.7.1.zip
mkdir confluence
mv atlassian-confluence-6.7.1/atlassian-confluence-6.7.1/* confluence/
chown -R confluence confluence/
chmod -R u=rwx,go-rwx confluence/
mkdir confluence-home
chown -R confluence confluence-home/
chmod -R u=rwx,go-rwx confluence-home/
echo "confluence.home=/data/vcg/confluence-home/" > $install_Dir/confluence/confluence/WEB-INF/classes/confluence-init.properties
su - confluence


