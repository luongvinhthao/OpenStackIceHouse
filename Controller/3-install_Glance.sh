#!/bin/bash
source config.cnf
set -e


echo "---------------------------- Install_Glance ----------------------------"

apt-get install glance python-glanceclient -y 
echo " Install glance python-glanceclient ---------------------------- done"
if [ ! -f /etc/glance/glance-api.conf.bak ]; then #check the file exist 
	#statements
	echo "back up file glance-api.conf"
	cp /etc/glance/glance-api.conf /etc/glance/glance-api.conf.bak
	echo "back up file glance-registry.conf"
	cp /etc/glance/glance-registry.conf /etc/glance/glance-registry.conf.bak
fi

echo "---------------------------- Edit glance-api.conf ----------------------------"
sed -i 's|sqlite_db = /var/lib/glance/glance.sqlite|connection = mysql://glance:GLANCE_DBPASS@HOST_NAME/glance|' /etc/glance/glance-api.conf
sed -i 's|HOST_NAME|'$HOST_NAME'|' /etc/glance/glance-api.conf
sed -i 's|GLANCE_DBPASS|'$GLANCE_DBPASS'|' /etc/glance/glance-api.conf


echo "Change sql connetction ---------------------------- done"
sleep 2

echo "Insert  [DEFAULT] ---------------------------- "
sed -i '/rabbit_host = localhost/arpc_backend = rabbit' /etc/glance/glance-api.conf
echo "Insert rpc_backend ---------------------------- done"
sed -i 's|rabbit_host = localhost|rabbit_host = '$HOST_NAME'|' /etc/glance/glance-api.conf
echo "Change rabbit_host ---------------------------- done"
sed -i 's|rabbit_password = guest|rabbit_password = '$RABBIT_PASS'|' /etc/glance/glance-api.conf
echo "Change rabbit_password ---------------------------- done"
echo "Insert  [DEFAULT] ---------------------------- done"
sleep 2

echo "Insert [keystone_authtoken] ---------------------------- "
sed -i '/auth_host = 127.0.0.1/aauth_uri = http://HOST_NAME:5000' /etc/glance/glance-api.conf
sed -i 's|HOST_NAME|'$HOST_NAME'|' /etc/glance/glance-api.conf
echo "Insert auth_uri ---------------------------- done"
sed -i 's|auth_host = 127.0.0.1|auth_host = '$HOST_NAME'|' /etc/glance/glance-api.conf
echo "Change auth_host ---------------------------- done"
sed -i 's|admin_tenant_name = %SERVICE_TENANT_NAME%|admin_tenant_name = '$SERVICE_TENANT_NAME'|'  /etc/glance/glance-api.conf
echo "Change admin_tenant_name ---------------------------- done"
sed -i 's|admin_user = %SERVICE_USER%|admin_user = glance|' /etc/glance/glance-api.conf
echo "Change admin_user ---------------------------- done"
sed -i 's|admin_password = %SERVICE_PASSWORD%|admin_password = '$GLANCE_PASS'|' /etc/glance/glance-api.conf
echo "Change admin_password ---------------------------- done"
echo "Insert [keystone_authtoken] ---------------------------- done"
sleep 2

echo "Insert [paste_deploy] ---------------------------- "
sed -i 's/#flavor=/flavor = keystone/' /etc/glance/glance-api.conf
echo "Change flavor ---------------------------- done"
echo "Insert [paste_deploy] ---------------------------- done"
sleep 2


echo "---------------------------- Edit glance-registry.conf ----------------------------"

sed -i 's|sqlite_db = /var/lib/glance/glance.sqlite|connection = mysql://glance:GLANCE_DBPASS@HOST_NAME/glance|g' /etc/glance/glance-registry.conf
sed -i 's|HOST_NAME|'$HOST_NAME'|' /etc/glance/glance-registry.conf
sed -i 's|GLANCE_DBPASS|'$GLANCE_DBPASS'|g' /etc/glance/glance-registry.conf
echo "Change sql connetction----------------------------done"
echo "Insert [paste_deploy] ---------------------------- done"
echo "Insert [keystone_authtoken]"

sed -i '/auth_host = 127.0.0.1/aauth_uri = http://HOST_NAME:5000' /etc/glance/glance-registry.conf
sed -i 's|HOST_NAME|'$HOST_NAME'|' /etc/glance/glance-api.conf
echo "Insert auth_uri ---------------------------- done"
sleep 2

sed -i 's|auth_host = 127.0.0.1|auth_host = '$HOST_NAME'|' /etc/glance/glance-registry.conf
echo "Change auth_host ---------------------------- done"
sed -i 's|admin_tenant_name = %SERVICE_TENANT_NAME%|admin_tenant_name = '$SERVICE_TENANT_NAME'|'  /etc/glance/glance-registry.conf
echo "Change admin_tenant_name ---------------------------- done"
sed -i 's|admin_user = %SERVICE_USER%|admin_user = glance|' /etc/glance/glance-registry.conf
echo "Change admin_user ---------------------------- done"
sed -i 's|admin_password = %SERVICE_PASSWORD%|admin_password = '$GLANCE_PASS'|' /etc/glance/glance-registry.conf
echo "Change admin_password ---------------------------- done"

sleep 2
echo "Insert [paste_deploy]"
sed -i 's/#flavor=/flavor = keystone/' /etc/glance/glance-registry.conf
echo "Change flavor ---------------------------- done"


echo "---------------------------- remove sqlite ----------------------------"

if [ -f /var/lib/glance/glance.sqlite ] ; then
		rm /var/lib/glance/glance.sqlite
fi

echo "---------------------------- Create table ----------------------------"
su -s /bin/sh -c "glance-manage db_sync" glance
sleep 6 
echo "---------------------------- Restart Glance Service ----------------------------"
service glance-registry restart
sleep 3 
service glance-api restart
sleep 3 

echo "---------------------------- Finish install glance----------------------------"