#!/bin/bash
source config.cnf
set -e

echo "---------------------------- Define users, tenants, and roles----------------------------"
echo $ADMIN_TOKEN
export OS_SERVICE_TOKEN="$ADMIN_TOKEN"
export OS_SERVICE_ENDPOINT="http://$HOST_NAME:35357/v2.0"

echo "--------------------------- check users---------------------------- "
sleep 6
keystone user-list

echo "--------------------------- Create tennant users---------------------------- "
keystone tenant-create --name=$ADMIN_TENANT_NAME --description="Admin Tenant"
echo "Create tennant admin ---------------------------- done "
keystone tenant-create --name=$SERVICE_TENANT_NAME --description="Service Tenant"
echo "Create tennant service ---------------------------- done "
keystone user-create --name=$ADMIN_TENANT_NAME --pass=$ADMIN_PASS --email=thaolvqn@gmail.com
echo "Create user admin ---------------------------- done "
keystone role-create --name=$ADMIN_TENANT_NAME
echo "Create role admin ---------------------------- done "
keystone user-role-add --user=$ADMIN_USER_NAME --tenant=$ADMIN_TENANT_NAME --role=$ADMIN_ROLE_NAME
echo "Add role admin to user admin---------------------------- done "


echo "--------------------------- Create demo tennant and user---------------------------- "
keystone tenant-create --name=$DEMO_TENANT_NAME --description="Demo Tenant"
echo "Create tennant demo ---------------------------- done "
keystone user-create --name=$DEMO_USER_NAME --pass=$ADMIN_PASS --email=thaolvqn@gmail.com
echo "Create user demo ---------------------------- done "
keystone user-role-add --user=$DEMO_USER_NAME --tenant=$DEMO_TENANT_NAME --role=_member_
echo "Add role _member_ to user demo---------------------------- done "

echo "--------------------------- Create glance---------------------------- "
keystone user-create --name=glance --pass=$GLANCE_PASS --email=thaolvqn@gmail.com
echo "Create user glance ---------------------------- done "
keystone user-role-add --user=glance --tenant=$SERVICE_TENANT_NAME --role=admin
echo "Add role admin to user glance---------------------------- done "

echo "--------------------------- Create nova---------------------------- "
keystone user-create --name=nova --pass=$NOVA_PASS --email=thaolvqn@gmail.com
echo "Create user nova ---------------------------- done "
keystone user-role-add --user=nova --tenant=$SERVICE_TENANT_NAME --role=admin
echo "Add role admin to user nova---------------------------- done "

echo "--------------------------- Create cinder---------------------------- "
keystone user-create --name=cinder --pass=$CINDER_PASS --email=thaolvqn@gmail.com
echo "Create user nova ---------------------------- done "
keystone user-role-add --user=cinder --tenant=$SERVICE_TENANT_NAME --role=admin
echo "Add role admin to user cinder---------------------------- done "
echo "--------------------------- Finish---------------------------- "