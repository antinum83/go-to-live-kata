#!/bin/bash

#cfr https://codex.wordpress.org/Installing_WordPress

if [ "$#" -ne 4 ]
then
	echo "Usage: ./xpeppers.sh <version|latest> <wordpress_db_name> <mysql_user> <mysql_password>"
exit 1
fi

version=$1
dbname=$2
mysqluser=$3
mysqlpasswd=$4

echo "Cleaning up files"
rm -rf /tmp/wordpress*
sudo rm -rf /var/www/html/wordpress*

echo "Testing network connection"
if [[ "$(ping -c 1 8.8.8.8 | grep '100% packet loss' )" != "" ]]
then
	echo "Internet isn't present"
	exit 1
else
	echo "Internet connection OK"
fi

echo "Downloading Wordpress version ${version}"
wget -c https://wordpress.org/wordpress-${version}.tar.gz -P /tmp
if [[ "$?" -ne 0 ]]
then
	echo "Errors getting wordpress ${version}. Aborting."
	exit 1
fi 

echo "Downloading md5"
wget -c https://wordpress.org/wordpress-${version}.tar.gz.md5 -P /tmp
if [[ "$?" -ne 0 ]]
then
	echo "Errors getting wordpress ${version} MD5. Aborting."
	exit 1
fi

echo "Calculating md5 for Wordpress"
md5=$(md5sum /tmp/wordpress-${version}.tar.gz | awk '{print $1}')
echo "Comparing md5"
if [[ $(cat /tmp/wordpress-${version}.tar.gz.md5) != "$md5" ]]
then
	echo "Md5 are different. Aborting."
	exit 1
else
	echo "Md5 check ok"
fi

echo "Installing wordpress prerequisites"
sudo apt-get install apache2 mysql-server php5 php5-mysqlnd-ms
if [[ "$?" -ne 0 ]]
then
	echo "Errors getting wordpress prerequisites"
	exit 1
fi

echo "Setting up mysql"
cp mysql_template.sql mysql.sql
sed -i -e "s/db_name_here/$dbname/g" mysql.sql
sed -i -e "s/user_name_here/$mysqluser/g" mysql.sql
sed -i -e "s/password_here/$mysqlpasswd/g" mysql.sql

cat mysql.sql | mysql -u root -p
if [[ "$?" -ne 0 ]]
then
	echo "Errors configuring MySQL. Aborting."
	exit 1
fi
rm ./mysql.sql

echo "Extracting wordpress"
tar xfz /tmp/wordpress-${version}.tar.gz -C /tmp

echo "Modifying wp-config.php file"
mv /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php
sed -i -e "s/database_name_here/$dbname/g" /tmp/wordpress/wp-config.php
sed -i -e "s/username_here/$mysqluser/g" /tmp/wordpress/wp-config.php
sed -i -e "s/password_here/$mysqlpasswd/g" /tmp/wordpress/wp-config.php

while [[ $(grep 'put your unique phrase here' /tmp/wordpress/wp-config.php) != "" ]]
do
	rand=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
	sed -i -e "0,/put your unique phrase here/s//${rand}/" /tmp/wordpress/wp-config.php
done

sudo mv /tmp/wordpress /var/www/html/

if ! [[ -f /etc/apache2/conf-available/fqdn.conf ]]
then
	echo "ServerName localhost" | sudo tee /etc/apache2/conf-available/fqdn.conf
	sudo a2enconf fqdn
fi

sudo service apache2 restart
if [[ "$?" -ne 0 ]]
then
	echo "Errors restarting apache2. Aborting."
	exit 1
fi

echo "Installation OK. Launching Firefox..."

firefox http://localhost/wordpress/wp-admin/install.php


