# install wp-cli
if [ ! -f /bin/wp/wp-cli.phar ]; then
   sudo curl -o /bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
   sudo chmod +x /bin/wp
fi

mkdir -p ${wp-path}
yum install -y mysql

# install wordpress if not installed
# use public alb host name if wp domain name was empty
if ! \$$(wp core is-installed --path='${wp-path}' --allow-root); then
   sudo chown -R ${nginx_user}:${nginx_group} ${wp-path}

   sudo -u ${nginx_user} -i -- wp core download --locale='en_GB' --path='${wp-path}' --allow-root
   sudo -u ${nginx_user} -i -- wp core config --dbname='${mysql_db}' --dbuser='${mysql_user}' --dbpass='${mysql_pass}' --dbhost='${mysql_host}' --path='${wp-path}'
   sudo -u ${nginx_user} -i -- wp core install --url='${app_domain_name}' --title='${app_name} v${app_version}' --admin_user='${wordpress_admin_user}' --admin_password='${wordpress_admin_pass}' --path='${wp-path}' --admin_email='${wordpress_admin_email}'

   if [ ! -f ${wp-path}/opcache-instanceid.php ]; then
     wget -P ${wp-path}/ https://s3.amazonaws.com/aws-refarch/wordpress/latest/bits/opcache-instanceid.php
   fi

   sudo -u ${nginx_user} -i -- wp plugin install hide-my-wp --activate --path='${wp-path}'
   sudo -u ${nginx_user} -i -- wp plugin install wp-force-https --activate --path='${wp-path}'
   sudo -u ${nginx_user} -i -- wp plugin install use-google-libraries --activate --path='${wp-path}'
   sudo -u ${nginx_user} -i -- wp plugin install google-webfont-optimizer --activate --path='${wp-path}'

   # set permissions of wordpress site directories
   sudo chown -R ${nginx_user}:${nginx_group} ${wp-path}
   sudo chmod u+wrx ${wp-path}/wp-content/*
fi

if ! \$$(wp core is-installed --path='${wp-path}' --allow-root); then
  touch ${wp-path}/wordpress.failed
    else
   touch ${wp-path}/wordpress.initialized
   echo "-_-" >> ${wp-path}/health.html
fi