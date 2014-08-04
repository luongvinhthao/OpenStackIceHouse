#! /bin/bash
source config.cnf
set -e
echo "---------------------------- Install keystone ----------------------------"
apt-get install keystone -y
if [[ ! -f /etc/keystone/keystone.conf.bak ]]; then
	#statements
	cp /etc/keystone/keystone.conf /etc/keystone/keystone.conf.bak
fi


echo "---------------------------- Edit keystone.conf ----------------------------"
# sed -i 's#oldpath/to#newpath/to'
echo "change sql connection"
sed -i 's|sqlite:////var/lib/keystone/keystone.db|mysql://keystone:KEYSTONE_DBPASS@controller/keystone|g' /etc/keystone/keystone.conf
sleep 3
#remove the first character on the third line
sed -i  '3s/^.//' /etc/keystone/keystone.conf
sed -i 's/^[ \t]*//' /etc/keystone/keystone.conf #remove space ib front of line

sed -i 's|KEYSTONE_DBPASS|'$KEYSTONE_DBPASS'|g' /etc/keystone/keystone.conf && sed -i 's|ADMIN_TOKEN|'$ADMIN_TOKEN'|g' /etc/keystone/keystone.conf

sleep 3
echo "---------------------------- Create datebase ----------------------------"
su -s /bin/sh -c "keystone-manage db_sync" keystone
echo "---------------------------- Remove datebase default----------------------------"
sleep 3
if [ -f /var/lib/keystone/keystone.db ]; then
	rm /var/lib/keystone/keystone.db
fi


echo "---------------------------- Restart Keystone Service----------------------------"
service keystone restart
sleep 3
