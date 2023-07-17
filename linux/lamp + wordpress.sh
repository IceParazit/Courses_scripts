#!/bin/bash

# Установка Apache и PHP и добавление разрешения в фаервол
sudo apt update
sudo apt install -y apache2 php libapache2-mod-php php-mysql
sudo ufw allow in "Apache"
sudo ufw allow in "OpenSSH"
sudo ufw enable


# Переменные для mysql
DBuser="DB""$USER"
DBname="DB""$(shuf -i 1-100 -n 1)"

echo $DBuser >> /home/sadmin/info.txt
echo $DBname >> /home/sadmin/info.txt
DBuserPwd=$(sha256sum /home/sadmin/info.txt | head -c 32)
echo $DBuserPwd >> /home/sadmin/info.txt
Create_DBuser="CREATE USER '${DBuser}'@'localhost' IDENTIFIED BY '${DBuserPwd}';"
Creat_DB="CREATE DATABASE $DBname"
Grant_DB="GRANT ALL PRIVILEGES ON $DBname.* TO '${DBuser}'@'localhost' WITH GRANT OPTION;"

# Установка MySQL
sudo apt install -y mysql-server

# Установка Curl
sudo apt  install curl -y
# Установка WordPress
cd /tmp
curl -O https://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz
cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php
sed -i "s/database_name_here/"$DBname"/g" /tmp/wordpress/wp-config.php
sed -i "s/username_here/"$DBuser"/g" /tmp/wordpress/wp-config.php
sed -i "s/password_here/"$DBuserPwd"/g" /tmp/wordpress/wp-config.php
sudo chown -R $USER:$USER /var/www
sudo mkdir /var/www/wordpress/
sudo cp -R wordpress/* /var/www/wordpress
sudo chown -R root:root /var/www/
sudo chown -R www-data:www-data /var/www/wordpress/
sudo chmod -R 755 /var/www/wordpress/

# Создание базы данных MySQL для WordPress
sudo mysql -e "${Create_DBuser}"
sudo mysql -e "${Creat_DB}"
sudo mysql -e "${Grant_DB}"
sudo mysql -e "FLUSH PRIVILEGES;"


# Конфигурация Apache для WordPress
sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/wordpress.conf
sudo sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/wordpress|' /etc/apache2/sites-available/wordpress.conf
sudo a2dissite 000-default.conf
sudo a2ensite wordpress.conf
sudo a2enmod rewrite
sudo systemctl restart apache2
sudo chown -R $USER:$USER /etc/hosts
echo "192.168.8.194 wordpress.test www.wordpress.test" >> /etc/hosts
sudo chown -R root:root /etc/hosts
# Очистка временных файлов
rm /tmp/latest.tar.gz
rm -rf /tmp/wordpress

echo "Установка WordPress завершена. Перейдите к wordpress.test в вашем веб-браузере для настройки."
