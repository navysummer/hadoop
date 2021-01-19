#!/bin/bash
#---------------------generate ssh-keygen------------------------
source /tmp/config
key_path="/root/.ssh"
if [[ -d $key_path ]]; then
    rm -rf /root/.ssh/*
else
    mkdir -p /root/.ssh
fi

ssh-keygen -t rsa -P "" -f /root/.ssh/id_rsa
current_host=$(hostname -a)
hosts=$(cat /etc/hosts | grep -v local | grep -v ip6 | awk '{if(NF==2){print $2}else if(NF==3){print $3}}')
for host in hosts; do
    if [[ $current_host!=$host ]]; then
        expect << EOF
spawn ssh-copy-id root@172.17.0.2
expect "(yes/no)?" {send "yes\r"}
expect "password:" {send "${root_pass}\r"}
expect "#" {send "exit\r"}
EOF
    fi
done
