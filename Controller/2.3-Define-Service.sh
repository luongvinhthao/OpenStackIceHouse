#! /bin/bash 
source config.cnf
set -e
export OS_SERVICE_TOKEN="$ADMIN_TOKEN"
export OS_SERVICE_ENDPOINT="http://$HOST_NAME:35357/v2.0"
echo "--------------------------- Create Keystone Identity Service ---------------------------- "
keystone service-create --name=keystone --type=identity \
--description="Openstack Keystone Identity Service"

sleep 3
keystone endpoint-create \
  --service-id=$(keystone service-list | awk '/ identity / {print $2}') \
  --publicurl=http://$HOST_NAME:5000/v2.0 \
  --internalurl=http://$HOST_NAME:5000/v2.0 \
  --adminurl=http://$HOST_NAME:35357/v2.0

echo "--------------------------- Create Glance Image Service ---------------------------- "
keystone service-create --name=glance --type=image \
  --description="Openstack Glance Image Service"

sleep 3
keystone endpoint-create \
  --service-id=$(keystone service-list | awk '/ image / {print $2}') \
  --publicurl=http://$HOST_NAME:9292 \
  --internalurl=http://$HOST_NAME:9292 \
  --adminurl=http://$HOST_NAME:9292

echo "--------------------------- Create Nova Compute Service ---------------------------- "
keystone service-create --name=nova --type=compute \
  --description="Openstack Nova Compute Service"

sleep 3
keystone endpoint-create \
  --service-id=$(keystone service-list | awk '/ compute / {print $2}') \
  --publicurl=http://$HOST_NAME:8774/v2/%\(tenant_id\)s \
  --internalurl=http://$HOST_NAME:8774/v2/%\(tenant_id\)s \
  --adminurl=http://$HOST_NAME:8774/v2/%\(tenant_id\)s

echo "--------------------------- Create Cinder Volume Service ---------------------------- "
sleep 3
 keystone service-create --name=cinder --type=volume \
  --description="Openstack Cinder Volume Service"

  keystone endpoint-create \
  --service-id=$(keystone service-list | awk '/ volume / {print $2}') \
  --publicurl=http://$HOST_NAME:8776/v1/%\(tenant_id\)s \
  --internalurl=http://$HOST_NAME:8776/v1/%\(tenant_id\)s \
  --adminurl=http://$HOST_NAME:8776/v1/%\(tenant_id\)s

echo "--------------------------- Create Newtron Service ---------------------------- "
sleep 3

 keystone service-create --name=neutron --type=network \
  --description="Openstack Networking  Service"

   keystone endpoint-create \
  --service-id $(keystone service-list | awk '/ network / {print $2}') \
  --publicurl http://controller:9696 \
  --adminurl http://controller:9696 \
  --internalurl http://controller:9696



echo "--------------------------- Create variable ---------------------------- "
echo "export OS_USERNAME=admin" > admin-openrc.sh
echo "export OS_PASSWORD=openstack12345" >> admin-openrc.sh
echo "export OS_TENANT_NAME=admin" >> admin-openrc.sh
echo "export OS_AUTH_URL=http://$HOST_NAME:35357/v2.0" >> admin-openrc.sh
chmod +x admin-openrc.sh
cat  admin-openrc.sh >> /etc/profile
  echo "--------------------------- Finish define service ---------------------------- "

