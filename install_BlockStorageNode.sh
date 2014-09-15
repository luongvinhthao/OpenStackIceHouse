#!/usr/bin/bash 
source config.cnf
set -e 

echo "---------------------------- Update ubuntu package ----------------------------"
apt-get install -y software-properties-common
apt-get install -y python-software-properties && add-apt-repository cloud-archive:icehouse -y
apt-get update && apt-get -y upgrade && apt-get -y dist-upgrade 

echo "---------------------------- Install and config NTP ----------------------------"
apt-get install -y ntp

echo "---------------------------- Install BlockStorage on BlockStorageNode ----------------------------"
apt-get install lvm2
echo "Install lvm2----------------------------done"
pvcreate /dev/sdb
vgcreate cinder-volumes /dev/sdb
echo "Create the LVM physical and logical volumes---------------------------- done"

if [[ ! -f /etc/lvm/lvm.conf.bak ]]; then
	#statements
	cp /etc/lvm/lvm.conf /etc/lvm/lvm.conf.bak
fi
echo "Edit /etc/lvm/lvm.conf---------------------------- done"

apt-get install cinder-volume python-mysqldb -y 

if [[ ! -f /etc/cinder/cinder.conf.bak ]]; then
	#statements
	cp /etc/cinder/cinder.conf /etc/cinder/cinder.conf.bak
fi
cat << EOF > /etc/cinder/cinder.conf

[DEFAULT]
rootwrap_config = /etc/cinder/rootwrap.conf
api_paste_confg = /etc/cinder/api-paste.ini
iscsi_helper = tgtadm
volume_name_template = volume-%s
volume_group = cinder-volumes
verbose = True
auth_strategy = keystone
state_path = /var/lib/cinder
lock_path = /var/lock/cinder
volumes_dir = /var/lib/cinder/volumes

# add new line to config blockstorage node 
rpc_backend = cinder.openstack.common.rpc.impl_kombu
rabbit_host = controller
rabbit_port = 5672
rabbit_userid = guest
rabbit_password = $RABBIT_PASS


glance_host = controller
[database]

connection = mysql://cinder:$CINDER_DBPASS@controller/cinder
[keystone_authtoken]
auth_uri = http://controller:5000
auth_host = controller
auth_port = 35357
auth_protocol = http
admin_tenant_name = service
admin_user = cinder
admin_password = $CINDER_PASS

EOF

echo "Edit /etc/cinder/cinder.conf---------------------------- done"

echo "---------------------------- Restart Cinder Service  ----------------------------"
service cinder-volume restart
service tgt restart
i= egrep -c '(vmx|svm)' /proc/cpuinfo
echo $i
if [[ i -eq 0 ]]; then
	#statements
	echo "0"
else
	echo "1"
fi