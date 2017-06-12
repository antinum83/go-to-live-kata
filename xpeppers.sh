#!/bin/bash

version=$1

echo "Downloading Wordpress version ${version}"
wget -c https://wordpress.org/wordpress-${version}.zip -P /tmp
echo "Downloading md5"
wget -c https://wordpress.org/wordpress-${version}.zip.md5 -P /tmp

echo "Calculating md5 for Wordpress"
md5=$(md5sum /tmp/wordpress-${version}.zip | awk '{print $1}')
echo "Comparing md5"
if [[ $(cat /tmp/wordpress-${version}.zip.md5) != "$md5" ]]
then
	echo "Md5 are different. Aborting."
	exit 0
else
	echo "Md5 check ok"
fi

echo "Installing wordpress requisites"
sudo apt-get install apache2 mysql-server php5

echo "Setting up mysql"
cat mysql.sql | mysql -u root -p
