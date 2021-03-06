#!/usr/bin/bash 
source config.cnf
set -e 


echo "---------------------------- Update ubuntu package ----------------------------"
apt-get install -y software-properties-common
apt-get install -y python-software-properties && add-apt-repository cloud-archive:icehouse -y
apt-get update && apt-get -y upgrade && apt-get -y dist-upgrade 

echo "---------------------------- Config hostname on ubuntu ----------------------------"
hostname $HOST_NAME_COMPUTE
echo "$HOST_NAME_COMPUTE" > /etc/hostname

echo "---------------------------- Install and config NTP ----------------------------"
apt-get install -y ntp
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf 
echo "---------------------------- Restart NTP ----------------------------"
sleep 3
service ntp restart
echo "---------------------------- Install python-mysqldb ----------------------------"
apt-get install python-mysqldb -y 
echo "---------------------------- Install Messaging server cho ubuntu ----------------------------"
apt-get install -y rabbitmq-server
echo "$RABBIT_PASS"
rabbitmqctl change_password guest $RABBIT_PASS


echo "---------------------------- Restart Rabbit and Finish ----------------------------"
sleep 2
service rabbitmq-server restart
sleep 2
init 6
echo "---------------------------- Finish ----------------------------"

 
