#!/usr/bin/bash 
source config.cnf
set -e 

echo "---------------------------- Install Dashboard ----------------------------"
apt-get install -y  apache2 memcached libapache2-mod-wsgi openstack-dashboard

apt-get remove --purge openstack-dashboard-ubuntu-theme -y


sed -i 's|OPENSTACK_HOST = "127.0.0.1"|OPENSTACK_HOST = "'$HOST_NAME'"|' /etc/openstack-dashboard/local_settings.py


echo "---------------------------- Restart service ----------------------------"
service apache2 restart
service memcached restart