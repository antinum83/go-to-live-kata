#!/bin/bash

echo "Cleaning up files"
rm -rf /tmp/wordpress*
sudo rm -rf /var/www/html/wordpress*

version=$1

if [[ "$version" == "" ]]
then
	echo "Usage: ./xpeppers.sh <version|latest>"
	exit 1
fi 

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
echo "Downloading md5"
wget -c https://wordpress.org/wordpress-${version}.tar.gz.md5 -P /tmp

echo "Calculating md5 for Wordpress"
md5=$(md5sum /tmp/wordpress-${version}.tar.gz | awk '{print $1}')
echo "Comparing md5"
if [[ $(cat /tmp/wordpress-${version}.tar.gz.md5) != "$md5" ]]
then
	echo "Md5 are different. Aborting."
	exit 0
else
	echo "Md5 check ok"
fi

echo "Installing wordpress prerequisites"
sudo apt-get install apache2 mysql-server php5

echo "Setting up mysql"
cat mysql.sql | mysql -u root -p

echo "Extracting wordpress"
tar xfz /tmp/wordpress-${version}.tar.gz -C /tmp

echo "Modifying wp-config.php file"
cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php
sed -i -e 's/database_name_here/wordpress/g' /tmp/wordpress/wp-config.php
sed -i -e 's/username_here/testuser/g' /tmp/wordpress/wp-config.php
sed -i -e 's/password_here/password/g' /tmp/wordpress/wp-config.php

while [[ $(grep 'put your unique phrase here' /tmp/wordpress/wp-config.php) != "" ]]
do
	rand=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
	sed -i -e "0,/put your unique phrase here/s//${rand}/" /tmp/wordpress/wp-config.php
done

sudo mv /tmp/wordpress /var/www/html/

echo "Done!"
