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
apt install ca-certificates apt-transport-https lsb-release curl nano unzip software-properties-common pwgen -y

#apache2
apt install apache2 -y

#php7.4
add-apt-repository ppa:ondrej/php
apt update
apt install php7.4 php7.4-cli php7.4-curl php7.4-gd php7.4-intl php7.4-json php7.4-mbstring php7.4-mysql php7.4-opcache php7.4-readline php7.4-xml php7.4-xsl php7.4-zip php7.4-bz2 libapache2-mod-php7.4 -y

# mariaDB
apt install mariadb-server -y
rootPasswordDB=$(pwgen -s 32 1)
adminPasswordDB=$(pwgen -s 32 1)
(echo ""; echo "y"; echo rootPasswordDB; echo "y"; echo "y"; echo "y"; echo "y") | mysql_secure_installation

#phpmyadmin
cd /usr/share
wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.zip -O phpmyadmin.zip
unzip phpmyadmin.zip
rm phpmyadmin.zip
mv phpMyAdmin-*-all-languages phpmyadmin
cd phpmyadmin
cat > config.inc.php <<EOF
\$cfg['blowfish_secret'] = '$(pwgen -s 32 1)';
$cfg['Servers'][\$i]['controluser'] = 'pma';
$cfg['Servers'][\$i]['controlpass'] = '$rootPasswordDB';

$cfg['TempDir'] = '/var/lib/phpmyadmin/tmp';
EOF
mariadb < "GRANT SELECT, INSERT, UPDATE, DELETE ON phpmyadmin.* TO 'pma'@'localhost' IDENTIFIED BY 'password';"
mariadb < "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' IDENTIFIED BY '$adminPasswordDB' WITH GRANT OPTION;";
mariadb < sql/create_tables.sql
chmod -R 0755 phpmyadmin
mkdir /usr/share/phpmyadmin/tmp/
wget https://raw.githubusercontent.com/gabrielix29/webserver-install/master/phpmyadmin.conf -P /etc/apache2/conf-available/
cd /etc/apache2/conf-available/
a2enconf phpmyadmin.conf
systemctl restart apache2
chown -R www-data:www-data /usr/share/phpmyadmin/

echo -e "\033[42mInstall successfull\033[0m"
echo "DB root password: $rootPasswordDB"
echo "DB admin password: $adminPasswordDB"

exit
