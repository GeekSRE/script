#!/bin/bash
#author=zhy
#date=2017-12-07
set -e
SHURL="http://sh.ops.biyao.com/"
SHURL_DNS=`grep "192.168.99.9 sh.ops.biyao.com" /etc/hosts|wc -l`
###
if [ $SHURL_DNS -eq 1 ];then
    echo "sh.ops.biyao.com   dns (#/etc/hosts#) is ok."
else
    echo "### sh.ops.biyao.com dns host" >> /etc/hosts
    echo "192.168.99.9 sh.ops.biyao.com" >> /etc/hosts
    echo "sh.ops.biyao.com   dns (#/etc/hosts#) is ok."
fi
###add sshkey
    curl -o /tmp/odc.pub $SHURL/script/ssh_odc.pub
    mkdir -p /root/.ssh/
    cat /tmp/odc.pub >> /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
