
#!/usr/bin/bash 
source config.cnf
set -e 

echo "---------------------------- Install Block Storage ----------------------------"
apt-get install  cinder-api cinder-scheduler -y 


echo "---------------------------- Edit /etc/cinder/cinder.conf ----------------------------"

if [[ ! -f /etc/cinder/cinder.conf  ]]; then
	#statements
	cp /etc/cinder/cinder.conf /etc/cinder/cinder.conf.bak
	echo "Back up file config ---------------------------- done"
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

# add new line to config block storage -----------------------------------
rpc_backend = cinder.openstack.common.rpc.impl_kombu
rabbit_host = controller
rabbit_port = 5672
rabbit_userid = guest
rabbit_password = $RABBIT_PASS
[database]

connection = mysql://cinder:$CINDER_DBPASS@$HOST_NAME/cinder

[keystone_authtoken]
auth_uri = http://controller:5000
auth_host = controller
auth_port = 35357
auth_protocol = http
admin_tenant_name = service
admin_user = cinder
admin_password = $CINDER_PASS

EOF

echo "Edit file cinde.conf ---------------------------- done"
echo "---------------------------- Create table ----------------------------"
 su -s /bin/sh -c "cinder-manage db sync" cinder

echo "---------------------------- Restart service ----------------------------"
  service cinder-scheduler restart
  service cinder-api restart

  echo "---------------------------- Finish ----------------------------"