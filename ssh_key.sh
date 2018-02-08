#!/bin/bash
#author=zhy
#date=2018-02-07
set -e

###add sshkey
if [ `cat ~/.ssh/authorized_keys |grep 'ops.vcg.com'|wc -l` -ge 1 ];then
    echo 'ops.vcg.com key is already exists ！'
    exit 0
fi

cat > /tmp/vcg.pub <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDOrp4iXQWijQuf/k9XlI7ITnJaEFKOKDWgspDVF7oX0joXgOLM2LcSJm+XmtUozWhdnQ62hGQr2CE9whQRDNuFcHf8oDwog3wzbCPY2qQdp8cibFKlch0pIhzTGZJDVbGEa/uhHH+OWfiVCFXRbzPrEr6DHjbUgkdX9YESq84a0d0gtGit/hFjXeqU36RDMCX2JFpA7hYre41kS5xjJjQvkwSaqn21cTi6OPScw+y6L12As8iI8Bn9YzBM12IAyTL86LuHPyIS12vmW5U6CCYkzPnW6gUrRBrK+99rJ4d6M0zyF4zpFRV/YWEp3k20vQZ4yLnBPU1ivSWI0T1IFgfx root@ops.vcg.com
EOF

mkdir -p /root/.ssh/
cat /tmp/vcg.pub >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
echo 'ssh_vcg_key is set ok!'    
