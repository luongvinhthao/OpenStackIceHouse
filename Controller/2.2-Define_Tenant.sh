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
keystone tenant-create --name=$SERVICE_TENANT_NAME --description="Service Tenant"

keystone user-create --name=$ADMIN_TENANT_NAME --pass=$ADMIN_PASS --email=thaolvqn@gmail.com

keystone role-create --name=$ADMIN_TENANT_NAME
keystone user-role-add --user=$ADMIN_USER_NAME --tenant=$ADMIN_TENANT_NAME --role=$ADMIN_ROLE_NAME
echo "--------------------------- Create demo tennant and user---------------------------- "
keystone tenant-create --name=$DEMO_TENANT_NAME --description="Demo Tenant"
keystone user-create --name=$DEMO_USER_NAME --pass=$ADMIN_PASS --email=thaolvqn@gmail.com
keystone user-role-add --user=$DEMO_USER_NAME --tenant=$DEMO_TENANT_NAME --role=_member_



keystone user-create --name=glance --pass=$GLANCE_PASS --email=thaolvqn@gmail.com
keystone user-role-add --user=glance --tenant=$SERVICE_TENANT_NAME --role=admin

keystone user-create --name=nova --pass=$NOVA_PASS --email=thaolvqn@gmail.com
keystone user-role-add --user=nova --tenant=$SERVICE_TENANT_NAME --role=admin

keystone user-create --name=cinder --pass=$CINDER_PASS --email=thaolvqn@gmail.com
keystone user-role-add --user=cinder --tenant=$SERVICE_TENANT_NAME --role=admin
echo "--------------------------- Finish---------------------------- "