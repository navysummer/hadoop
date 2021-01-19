#!/bin/bash
#------------------------------config start----------------------------------------
project_path=$(cd $(dirname $0); pwd)
echo ${project_path}/config

# exit
source ${project_path}/config
#-----------------------------config end-------------------------------------------
docker network create --driver bridge --subnet=${subnet} --gateway=${gateway} ${netname}
docker pull navysummer/centos:7.8
#-----------------------------create node start------------------------------------
# master node
docker run -e TZ="Asia/Shanghai" --privileged -itd \
-h $master_name \
--name $master_name \
--network=${netname} \
--ip $master_ip \
--add-host ${slave1_name}:${slave1_ip} \
--add-host ${slave2_name}:${slave2_ip} \
--dns=$dns \
navysummer/centos:7.8 \
/usr/sbin/init

# slave1 node
docker run -e TZ="Asia/Shanghai" --privileged -itd \
-h $slave1_name \
--name $slave1_name \
--network=${netname} \
--ip $slave1_ip \
--add-host ${master_name}:${master_ip} \
--add-host ${slave2_name}:${slave2_ip} \
--dns=$dns \
navysummer/centos:7.8 \
/usr/sbin/init

#slave2 node
docker run -e TZ="Asia/Shanghai" --privileged -itd \
-h $slave2_name \
--name $slave2_name \
--network=${netname} \
--ip $slave2_ip \
--add-host ${master_name}:${master_ip} \
--add-host ${slave1_name}:${slave1_ip} \
--dns=$dns \
navysummer/centos:7.8 \
/usr/sbin/init

#---------------------create node end----------------------------------------------
#---------------------container config password start------------------------------
docker container exec $master_name bash -c "echo ${root_pass} | passwd --stdin root"
docker container exec $slave1_name bash -c "echo ${root_pass} | passwd --stdin root"
docker container exec $slave2_name bash -c "echo ${root_pass} | passwd --stdin root"
#---------------------container config password end--------------------------------
#---------------------container config ssh-keygen start----------------------------
docker container cp ${project_path}/sshconfig.sh ${master_name}:/tmp
docker container cp ${project_path}/sshconfig.sh ${slave1_name}:/tmp
docker container cp ${project_path}/sshconfig.sh ${slave2_name}:/tmp
docker container cp ${project_path}/config ${master_name}:/tmp
docker container cp ${project_path}/config ${slave1_name}:/tmp
docker container cp ${project_path}/config ${slave2_name}:/tmp

docker container exec $master_name bash -c "mkdir -p /root/.ssh;yum -y install expect"
docker container exec $slave1_name bash -c "mkdir -p /root/.ssh;yum -y install expect"
docker container exec $slave2_name bash -c "mkdir -p /root/.ssh;yum -y install expect"

docker container exec $master_name bash -c "/bin/bash /tmp/sshconfig.sh"
docker container exec $slave1_name bash -c "/bin/bash /tmp/sshconfig.sh"
docker container exec $slave2_name bash -c "/bin/bash /tmp/sshconfig.sh"
#---------------------container config ssh-keygen end------------------------------
#---------------------container config hadoop start--------------------------------
docker container cp ${project_path}/hadoopConfig.sh ${master_name}:/tmp
docker container exec $master_name bash -c "/bin/bash /tmp/hadoopConfig.sh"
docker container cp ${project_path}/hadoopConfig.sh ${slave1_name}:/tmp
docker container exec $slave1_name bash -c "/bin/bash /tmp/hadoopConfig.sh"
docker container cp ${project_path}/hadoopConfig.sh ${slave2_name}:/tmp
docker container exec $slave2_name bash -c "/bin/bash /tmp/hadoopConfig.sh"
#---------------------container config hadoop end----------------------------------
