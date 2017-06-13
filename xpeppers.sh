#!/bin/bash

version=$1

if [[ "$version" == "" ]]
then
	echo "Usage: ./xpeppers.sh <version|latest>"
	exit 1
fi 

if [[ "$(ping -c 1 8.8.8.8 | grep '100% packet loss' )" != "" ]]
then
    echo "Internet isn't present"
    exit 1
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

echo "Installing wordpress requisites"
sudo apt-get install apache2 mysql-server php5

echo "Setting up mysql"
cat mysql.sql | mysql -u root -p

echo "Extracting wordpress"
tar xfz /tmp/wordpress-${version}.tar.gz -C /tmp

rm /tmp/wordpress-${version}.tar.gz*
