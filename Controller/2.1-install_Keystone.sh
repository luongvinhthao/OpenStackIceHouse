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

sed -i 's|sqlite:////var/lib/keystone/keystone.db|mysql://keystone:KEYSTONE_DBPASS@controller/keystone|g' /etc/keystone/keystone.conf
sed -i 's|KEYSTONE_DBPASS|'$KEYSTONE_DBPASS'|g' /etc/keystone/keystone.conf && sed -i 's|ADMIN|'$ADMIN_TOKEN'|g' /etc/keystone/keystone.conf
#remove the first character on the  line 13
sed -i  '13s/^.//' /etc/keystone/keystone.conf
sed -i 's/^[ \t]*//' /etc/keystone/keystone.conf #remove space ib front of line
echo "change sql connection and admin token---------------------------- done "

sleep 3


sed -i 's|#log_dir=<None>|log_dir = /var/log/keystone|' /etc/keystone/keystone.conf
echo "change log_dir= /var/log/keystone ---------------------------- done "

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

(crontab -l -u keystone 2>&1 | grep -q token_flush) || \
echo '@hourly /usr/bin/keystone-manage token_flush >/var/log/keystone/keystone-tokenflush.log 2>&1' >> /var/spool/cron/crontabs/keystone