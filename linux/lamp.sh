#!/bin/bash
sudo apt update
#установка апач + разрешение в фаерволе
sudo apt install apache2 -y
sudo ufw allow in "Apache"
sudo ufw allow in "OpenSSH"
sudo ufw enable
sudo apt install mysql-server -y
sudo apt install php libapache2-mod-php php-mysql -y
sudo apt  install curl -y

DBuser="DB""$USER"
DBname="DB""$(shuf -i 1-100 -n 1)"


echo $DBuser >> /home/sadmin/info.txt
echo $DBname >> /home/sadmin/info.txt
DBuserPwd=$(sha256sum /home/sadmin/info.txt | head -c 32)
echo $DBuserPwd >> /home/sadmin/info.txt

Create_DBuser="CREATE USER '${DBuser}'@'localhost' IDENTIFIED BY '${DBuserPwd}';"
Grant_DB="GRANT ALL PRIVILEGES ON $DBname.* TO '${DBuser}'@'localhost' WITH GRANT OPTION;"
Creat_DB="CREATE DATABASE $DBname"

sudo mysql -e "${Create_DBuser}"
sudo mysql -e "${Creat_DB}"
sudo mysql -e "${Grant_DB}"
sudo mysql -e "FLUSH PRIVILEGES;"

echo "имя базы -- " $DBname
echo "имя пользователя -- " $DBuser


sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/wordpress.conf
sudo sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/wordpress|' /etc/apache2/sites-available/wordpress.conf
sudo a2ensite wordpress.conf
sudo a2enmod rewrite
sudo systemctl restart apache2

#wordpress

wb_conf="// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', $DBname );
/** MySQL database username */
define( 'DB_USER', '${DBuser}' );
/** MySQL database password */
define( 'DB_PASSWORD', '${DBuserPwd}' );
/** MySQL hostname */
define( 'DB_HOST', 'localhost' );
/** Database Charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );
/** The Database Collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );
define('FS_METHOD', 'direct');

define( 'AUTH_KEY',         'put your unique phrase here' );
define( 'SECURE_AUTH_KEY',  'put your unique phrase here' );
define( 'LOGGED_IN_KEY',    'put your unique phrase here' );
define( 'NONCE_KEY',        'put your unique phrase here' );
define( 'AUTH_SALT',        'put your unique phrase here' );
define( 'SECURE_AUTH_SALT', 'put your unique phrase here' );
define( 'LOGGED_IN_SALT',   'put your unique phrase here' );
define( 'NONCE_SALT',       'put your unique phrase here' );

'$'table_prefix = 'wp_';



require_once ABSPATH . 'wp-settings.php';

if ( ! defined( 'ABSPATH' ) ) {

        define( 'ABSPATH', __DIR__ . '/' );

}

define( 'WP_DEBUG', false );"




cd /tmp
curl -O https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
touch /tmp/wordpress/.htaccess
touch /tmp/wordpress/wp-config.php
echo "$wb_conf" > /tmp/wordpress/wp-config.php
mkdir /tmp/wordpress/wp-content/upgrade
sudo cp -a /tmp/wordpress/. /var/www/html/wordpress
sudo chown -R www-data:www-data /var/www/html/wordpress
sudo find /var/www/html/wordpress -type d -exec chmod 750 {} \;
sudo find /var/www/html/wordpress -type f -exec chmod 640 {} \;




