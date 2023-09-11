#!/bin/bash

	sed -i "s/listen = \/run\/php\/php7.3-fpm.sock/listen = 9000/" "/etc/php/7.3/fpm/pool.d/www.conf";
	chown -R www-data:www-data /var/www/*;
	chown -R 755 /var/www/*;
	mkdir -p /run/php/;
	touch /run/php/php7.3-fpm.pid;

if [ ! -f /var/www/html/wp-config.php ]; then
	echo "Wordpress: setting up..."
	mkdir -p /var/www/html
	wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar;
	chmod +x wp-cli.phar; 
	mv wp-cli.phar /usr/local/bin/wp;
	cd /var/www/html;
	wp core download --allow-root;
	mv /var/www/wp-config.php /var/www/html/
	echo "Wordpress: creating users..."
	wp core install --allow-root --url="mkarakul.42.fr" --title="wordpress" --admin_user=${MYSQL_USER} --admin_password=${MYSQL_PASSWORD} --admin_email="mkarakul@mkarakul.com"
	wp user create --allow-root ${MYSQL_USER} "mkarakul@mkarakul.com" --user_pass=${MYSQL_PASSWORD};

	wp plugin install redis-cache --activate --allow-root
  wp plugin update --all --allow-root
  wp plugin activate redis-cache --allow-root
  wp redis enable --force --allow-root

	echo "Wordpress: set up!"
fi

exec "$@"
