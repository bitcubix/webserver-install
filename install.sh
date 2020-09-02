#!/bin/bash

echo "Install Apache2 with PHP7.4 MySQL and phpMyAdmin"
echo ""
if [ "$EUID" -ne 0 ]
  then
    echo "Please run as root"
    exit
fi

# requirements
apt update
apt upgrade -y
apt install ca-certificates apt-transport-https lsb-release curl nano unzip software-properties-common -y

#apache2
apt install apache2 -y

#php7.4
add-apt-repository ppa:ondrej/php
apt update
apt install php7.4 php7.4-cli php7.4-curl php7.4-gd php7.4-intl php7.4-json php7.4-mbstring php7.4-mysql php7.4-opcache php7.4-readline php7.4-xml php7.4-xsl php7.4-zip php7.4-bz2 libapache2-mod-php7.4 -y

# mariaDB
apt install mariadb-server -y
mysql_secure_installation

#phpmyadmin
wget
cd /usr/share
wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.zip -O phpmyadmin.zip
unzip phpmyadmin.zip
rm phpmyadmin.zip
mv phpMyAdmin-*-all-languages phpmyadmin
chmod -R 0755 phpmyadmin
