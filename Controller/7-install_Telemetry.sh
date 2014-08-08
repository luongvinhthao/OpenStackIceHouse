#!/bin/bash
source config.cnf
set -e

echo "---------------------------- Install_Telemetry ----------------------------"
apt-get install ceilometer-api ceilometer-collector ceilometer-agent-central \
  ceilometer-agent-notification ceilometer-alarm-evaluator ceilometer-alarm-notifier python-ceilometerclient -y
echo "---------------------------- Install_mongodb-server ----------------------------"
apt-get install mongodb-server -y
echo "---------------------------- Restart mongodb ----------------------------"
service mongodb restart
mongo --host controller --eval '
db = db.getSiblingDB("ceilometer");
db.addUser({user: "ceilometer",
            pwd: "CEILOMETER_DBPASS",
            roles: [ "readWrite", "dbAdmin" ]})'

if [[ ! -f /etc/ceilometer/ceilometer.conf.bak  ]]; then
	#statements
	cp /etc/ceilometer/ceilometer.conf /etc/ceilometer/ceilometer.conf.bak
fi
echo "---------------------------- Edit ceilometer.conf  ----------------------------"

sed -i "s|connection=sqlite:////var/lib/ceilometer/$sqlite_db|connection = mongodb://ceilometer:$CEILOMETER_DBPASS@$HOST_NAME:27017/ceilometer|" /etc/ceilometer/ceilometer.conf
echo "Change sql connetction ---------------------------- done"

sed -i "s|#metering_secret=change this or be hacked|metering_secret = $CEILOMETER_TOKEN|" /etc/ceilometer/ceilometer.conf
echo "Change ceilometer token ---------------------------- done"

sed -i "s|#rabbit_host=localhost|rabbit_host = $HOST_NAME|" /etc/ceilometer/ceilometer.conf
sed -i "s|#rabbit_password=guest|rabbit_password = $RABBIT_PASS|" /etc/ceilometer/ceilometer.conf
echo "Change rabbit  authentication ---------------------------- done"
sed -i "s|#log_dir=<None>|log_dir = /var/log/ceilometer|" /etc/ceilometer/ceilometer.conf
echo "Change log_dir---------------------------- done"

sed -i "s|#auth_strategy=keystone|auth_strategy = keystone|" /etc/ceilometer/ceilometer.conf
echo "Change keystone---------------------------- done"


sed -i "s|#auth_host=127.0.0.1|auth_host=$HOST_NAME|" /etc/ceilometer/ceilometer.conf
sed -i "s|#auth_port=35357|auth_port=35357|" /etc/ceilometer/ceilometer.conf
sed -i "s|#auth_protocol=https|auth_protocol=http|" /etc/ceilometer/ceilometer.conf
sed -i "s|#auth_uri=<None>|auth_uri = http://$HOST_NAME:5000|" /etc/ceilometer/ceilometer.conf
sed -i "s|#admin_tenant_name=admin|admin_tenant_name = $SERVICE_TENANT_NAME|" /etc/ceilometer/ceilometer.conf
sed -i "s|#admin_user=<None>|admin_user = ceilometer|" /etc/ceilometer/ceilometer.conf
sed -i "s|#admin_password=<None>|admin_password = $CEILOMETER_PASS|" /etc/ceilometer/ceilometer.conf
sleep 2
echo "Change keystone_authtoken---------------------------- done"


sed -i "s|#os_username=ceilometer|os_username = ceilometer|" /etc/ceilometer/ceilometer.conf
sed -i "s|#os_auth_url=http://localhost:5000/v2.0|os_auth_url = http://$HOST_NAME:5000/v2.0|" /etc/ceilometer/ceilometer.conf
sed -i "s|#os_tenant_name=admin|os_tenant_name = service|" /etc/ceilometer/ceilometer.conf
sed -i "s|#os_password=admin|os_password = $CEILOMETER_PASS|" /etc/ceilometer/ceilometer.conf

echo "Change service_credentials---------------------------- done"
keystone user-create --name=ceilometer --pass=$CEILOMETER_PASS --email=thaolvqn@gmail.com
keystone user-role-add --user=ceilometer --tenant=service --role=admin


 keystone service-create --name=ceilometer --type=metering \
  --description="Telemetry"

 keystone endpoint-create \
  --service-id=$(keystone service-list | awk '/ metering / {print $2}') \
  --publicurl=http://controller:8777 \
  --internalurl=http://controller:8777 \
  --adminurl=http://controller:8777

echo "----------------------------Restart service ---------------------------- "

for ii in /etc/init.d/ceilometer-*; do restart $(basename $ii); done
# service ceilometer-agent-central restart
# service ceilometer-agent-notification restart
# service ceilometer-api restart
# service ceilometer-collector restart
# service ceilometer-alarm-evaluator restart
# service ceilometer-alarm-notifier restart
