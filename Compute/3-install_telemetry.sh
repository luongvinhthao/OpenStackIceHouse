#!/bin/bash
source config.cnf
set -e

echo "---------------------------- Install_Telemetry_Compute ----------------------------"
apt-get install ceilometer-agent-compute -y 

echo "---------------------------- edit nova.conf ----------------------------"

if [[ ! -f /etc/nova/nova.conf.bak  ]]; then
	#statements
	cp /etc/nova/nova.conf /etc/nova/nova.conf.bak
fi

#sed -i "/glance_host=controller/a\instance_usage_audit = True\n\
#instance_usage_audit_period = hour\n\
#notify_on_state_change = vm_and_task_state\n\
#notification_driver = nova.openstack.common.notifier.rpc_notifier\n\
#notification_driver = ceilometer.compute.nova_notifier"  /etc/nova/nova.conf


echo "---------------------------- Edit ceilometer.conf  ----------------------------"


sed -i "s|#metering_secret=change this or be hacked|metering_secret = $CEILOMETER_TOKEN|" /etc/ceilometer/ceilometer.conf
echo "Change ceilometer token ---------------------------- done"

sed -i "s|#rabbit_host=localhost|rabbit_host = $HOST_NAME|" /etc/ceilometer/ceilometer.conf
sed -i "s|#rabbit_password=guest|rabbit_password = $RABBIT_PASS|" /etc/ceilometer/ceilometer.conf
echo "Change rabbit  authentication ---------------------------- done"
sed -i "s|#log_dir=<None>|log_dir = /var/log/ceilometer|" /etc/ceilometer/ceilometer.conf
echo "Change log_dir---------------------------- done"

sed -i "s|#auth_strategy=keystone|auth_strategy = keystone|" /etc/ceilometer/ceilometer.conf
echo "Change keystone---------------------------- done"

sed -i "s|#os_username=ceilometer|os_username = ceilometer|" /etc/ceilometer/ceilometer.conf
sed -i "s|#os_auth_url=http://localhost:5000/v2.0|os_auth_url = http://$HOST_NAME:5000/v2.0|" /etc/ceilometer/ceilometer.conf
sed -i "s|#os_tenant_name=admin|os_tenant_name = service|" /etc/ceilometer/ceilometer.conf
sed -i "s|#os_password=admin|os_password = $CEILOMETER_PASS|" /etc/ceilometer/ceilometer.conf

echo "Change service_credentials---------------------------- done"

echo "----------------------------Restart service ---------------------------- "
service ceilometer-agent-compute restart


