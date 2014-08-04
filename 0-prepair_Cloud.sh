#!/usr/bin/bash 
source config.cnf
set -e 


echo "---------------------------- cap nhat cac goi cho ubuntu ----------------------------"

apt-get install -y python-software-properties && add-apt-repository cloud-archive:icehouse -y
apt-get update && apt-get -y upgrade && apt-get -y dist-upgrade 

echo "---------------------------- Khai bao Hostname cho ubuntu ----------------------------"
hostname $HOST_NAME
echo "$HOST_NAME" > /etc/hostname

echo "---------------------------- Cai dat & cau hinh NTP ----------------------------"
apt-get install -y ntp

echo "---------------------------- Khoi dong lai NTP ----------------------------"
sleep 3
service ntp restart
echo "---------------------------- install Messaging server cho ubuntu ----------------------------"
apt-get install -y rabbitmq-server
echo "$RABBIT_PASS"
rabbitmqctl change_password guest $RABBIT_PASS

echo "---------------------------- Khoi dong lai may ----------------------------"
sleep 2
service rabbitmq-server restart
sleep 2
init 6


 
