#!/usr/bin/bash 
source config.cnf
set -e 

echo "---------------------------- Update ubuntu package ----------------------------"

apt-get install -y python-software-properties && add-apt-repository cloud-archive:icehouse -y
apt-get update && apt-get -y upgrade && apt-get -y dist-upgrade 

echo "---------------------------- Install and config NTP ----------------------------"
apt-get install -y ntp


apt-get install neutron-plugin-ml2 neutron-plugin-openvswitch-agent openvswitch-datapath-dkms \
  neutron-l3-agent neutron-dhcp-agent