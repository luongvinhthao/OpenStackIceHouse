#! /bin/bash 
source config.cnf
set -e
echo "---------------------------- install mysql-server ----------------------------"
echo mysql-server mysql-server/root_password password $MYSQL_ADMIN_PASS | debconf-set-selections
echo mysql-server mysql-server/root_password_again password $MYSQL_ADMIN_PASS | debconf-set-selections
echo $MYSQL_ADMIN_PASS
sleep 3 
apt-get install expect -y 
apt-get install python-mysqldb mysql-server  -y 

mysql_install_db

MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"$MYSQL_ADMIN_PASS\r\"
expect \"Change the root password?\"
send \"n\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"n\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")
 
echo "$MYSQL"
apt-get remove --purge -y expect

#/etc/mysql/my.cnf and set the bind-addressds
echo "---------------------------- set bind-address at etc/mysql/my.cnf ----------------------------"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf

sleep 2
 service mysql restart


echo "---------------------------- create database ----------------------------"

sleep 5

cat << EOF | mysql -uroot -p$MYSQL_ADMIN_PASS
DROP DATABASE IF EXISTS keystone;
DROP DATABASE IF EXISTS glance;
DROP DATABASE IF EXISTS nova;
DROP DATABASE IF EXISTS cinder;

CREATE DATABASE nova;
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY '$NOVA_DBPASS';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '$NOVA_DBPASS';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'controller' IDENTIFIED BY '$NOVA_DBPASS';
CREATE DATABASE glance;

GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY '$GLANCE_DBPASS';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY '$GLANCE_DBPASS';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'controller' IDENTIFIED BY '$GLANCE_DBPASS';

CREATE DATABASE keystone;
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '$KEYSTONE_DBPASS';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '$KEYSTONE_DBPASS';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'controller' IDENTIFIED BY '$KEYSTONE_DBPASS';

CREATE DATABASE cinder;
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' IDENTIFIED BY '$CINDER_DBPASS';
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY '$CINDER_DBPASS';
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'controller' IDENTIFIED BY '$CINDER_DBPASS';

FLUSH PRIVILEGES;
EOF
exit 0 

echo "---------------------------- finish ----------------------------"