#!/bin/bash

APACHE_DIR="/etc/apache2"
APACHE_DIR_SITE_AVAILABLE="/etc/apache2/sites-available"
APACHE_DIR_SITE_ENABLED="/etc/apache2/sites-enabled"
APACHE_BOT_CERTIFICATE="/etc/apache2/certbot"

apache_help () {
	echo "Apache SHELL"
	echo "apache configure"
	echo "apache start"
	echo "apache stop"
	echo "apache restart"
	echo "apache reload"
	echo "apache plugin [start | stop] --all"
	echo "apache plugin [start | stop] [name]"
	echo "apache site install [name | 000-default]"
	}

apache_start () {
	systemctl start apache2
	}

apache_stop () {
	systemctl stop apache2
	}

apache_restart () {
	systemctl restart apache2
	}

apache_reload () {
	systemctl reload apache2
	}

apache_plugin () {
	apache2ctl -t -D DUMP_MODULES
	}

apache_plugin_start () {
	if [ "$1" == "--all" ]
		then
			a2enmod rewrite
			a2enmod proxy
			a2enmod proxy_http
			a2enmod proxy_ajp
			a2enmod proxy_balancer
			a2enmod proxy_wstunnel
			a2enmod security2
	else
		a2enmod $1
		fi
	}

apache_plugin_stop () {
	if [ "$1" == "--all" ]
		then
			a2dismod rewrite
			a2dismod proxy
			a2dismod proxy_http
			a2dismod proxy_ajp
			a2dismod proxy_balancer
			a2dismod proxy_wstunnel
			a2dismod security2
	else
		a2dismod $1
		fi
	}

apache_site_start () {
	a2ensite $1.conf
	}

apache_site_stop () {
	a2dissite $1.conf
	}

apache_generate_commit () {
	if [ "$1" == "--configuration" ]
		then
		cp /tmp/apache.conf $APACHE_DIR/apache2.conf
		cp /tmp/apache-ssl.conf $APACHE_DIR/ssl.conf
		rm -rf $APACHE_DIR_SITE_AVAILABLE/*
		rm -rf $APACHE_DIR_SITE_ENABLED/*
		if [ -d /var/www ]
			then
				rm -rf /var/www/*
		else
			mkdir /var/www
			fi
		if [ -d /var/log/www ]
			then
				rm -rf /var/log/www/*
		else
			mkdir /var/log/www
			fi
	else
		cp /tmp/v-host-\($1\).conf $APACHE_DIR_SITE_AVAILABLE/$1.conf
		rm -rf /var/log/www/$1
		mkdir /var/log/www/$1
		rm -rf /var/www/$1
		mkdir /var/www/$1
		mkdir /var/www/$1/public
		mkdir /var/www/$1/ssl
		mkdir /var/www/$1/ssl/.well-known
		mkdir /var/www/$1/ssl/.well-known/acme-chalenge
		mkdir /var/www/$1/ssl/certificate
		fi
	}

apache_generate_file_index () {
	echo -en "
<VirtualHost *:80>
	DocumentRoot \"/var/www/$1/public\"
	CustomLog \"/var/log/www/$1/access.log\" common
	ErrorLog \"/var/log/www/$1/error.log\"
	ServerAdmin admin@$1
	RewriteEngine On
	# RewriteCond %{SERVER_NAME} !=$2
	# RewriteRule ^ - [R=403]
	ErrorDocument 400 \"Error Bad Request\"
	ErrorDocument 403 \"Error Forbidden\"
	ErrorDocument 404 \"Error Not Found\"
	ErrorDocument 500 \"Error Internal Server\"
	ErrorDocument 503 \"Error Service Not Found ...\"
</VirtualHost>
" > /tmp/v-host-\($1\).conf
	}

apache_generate_file_config () {
	echo -en "
<VirtualHost *:80>
	DocumentRoot \"/var/www/$1/public\"
	CustomLog \"/var/log/www/$1/access.log\" common
	ErrorLog \"/var/log/www/$1/error.log\"
	ServerAdmin admin@$1
	ServerName $1
	ProxyRequests On
	ProxyPreserveHost On
	ProxyVia Full
	<Proxy *>
		Require all granted
	</Proxy>
	<Location />
		<RequireAll>
			Require all granted
			# Require not ip 127.0.0.1
		</RequireAll>
		ProxyPass http://$1:3000/
		ProxyPassReverse http://$1:3000/
	</Location>
	<Location /static/>
		ProxyPass !
	</Location>
	RewriteEngine On
	RewriteCond %{SERVER_NAME} !=$1
	RewriteRule ^ - [R=403]
	# RewriteCond %{SERVER_NAME} =*.$1 [OR]
	# RewriteCond %{SERVER_NAME} =$1
	# RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]
	ErrorDocument 400 \"Error Bad Request\"
	ErrorDocument 403 \"Error Forbidden\"
	ErrorDocument 404 \"Error Not Found\"
	ErrorDocument 500 \"Error Internal Server\"
	ErrorDocument 503 \"Error Service Not Found ...\"
</VirtualHost>

<VirtualHost *:80>
	DocumentRoot \"/var/www/$1/public\"
	CustomLog \"/var/log/www/$1/access.log\" common
	ErrorLog \"/var/log/www/$1/error.log\"
	ServerAdmin admin@$1
	ServerAlias *.$1
	ProxyRequests On
	ProxyPreserveHost On
	ProxyVia Full
	<Proxy *>
		Require all granted
	</Proxy>
	<Location />
		<RequireAll>
			Require all granted
			# Require not ip 127.0.0.1
		</RequireAll>
		ProxyPass http://$1:3000/
		ProxyPassReverse http://$1:3000/
	</Location>
	<Location /static/>
		ProxyPass !
	</Location>
	RewriteEngine On
	RewriteCond %{HTTP:Upgrade} websocket [NC]
	RewriteCond %{HTTP:Connection} upgrade [NC]
	RewriteRule ^/?(.*) \"ws://edge.$1:3000/\$1\" [P,L]
	RewriteCond %{SERVER_NAME} ^\$
	RewriteRule $1\$ - [R=403]
	# RewriteCond %{SERVER_NAME} =*.$1 [OR]
	# RewriteCond %{SERVER_NAME} =$1
	# RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]
	ErrorDocument 400 \"Error Bad Request\"
	ErrorDocument 403 \"Error Forbidden\"
	ErrorDocument 404 \"Error Not Found\"
	ErrorDocument 500 \"Error Internal Server\"
	ErrorDocument 503 \"Error Service Not Found ...\"
</VirtualHost>
" > /tmp/v-host-\($1\).conf
	}

apache_generate_file_configuration () {
	echo -en "
ServerRoot \"/etc/apache2\"
ServerName apache
DefaultRuntimeDir \${APACHE_RUN_DIR}
PidFile \${APACHE_PID_FILE}
Timeout 300
KeepAlive On
MaxKeepAliveRequests 100
KeepAliveTimeout 5
User \${APACHE_RUN_USER}
Group \${APACHE_RUN_GROUP}
HostnameLookups Off
ErrorLog \${APACHE_LOG_DIR}/error.log
LogLevel warn
IncludeOptional mods-enabled/*.load
IncludeOptional mods-enabled/*.conf
Include ports.conf
AccessFileName .htaccess
<Directory />
	Options FollowSymLinks
	AllowOverride None
	Require all denied
</Directory>
<Directory /var/www/>
	Options Indexes FollowSymLinks
	AllowOverride None
	Require all granted
</Directory>
<Directory /usr/share/>
	AllowOverride None
	Require all granted
</Directory>
<FilesMatch \"^\.ht\">
	Require all denied
</FilesMatch>
LogFormat \"%v:%p %h %l %u %t \\\"%r\\\" %>s %O \\\"%{Referer}i\\\" \\\"%{User-Agent}i\\\"\" vhost_combined
LogFormat \"%h %l %u %t \\\"%r\\\" %>s %O \\\"%{Referer}i\\\" \\\"%{User-Agent}i\\\"\" combined
LogFormat \"%h %l %u %t \\\"%r\\\" %>s %O\" common
LogFormat \"%{Referer}i -> %U\" referer
LogFormat \"%{User-Agent}i\" agent
IncludeOptional conf-enabled/*.conf
IncludeOptional sites-enabled/*.conf
ErrorDocument 400 \"<!--400-->\"
ErrorDocument 403 \"<!--403-->\"
ErrorDocument 404 \"<!--404-->\"
ErrorDocument 500 \"<!--500-->\"
ErrorDocument 503 \"<!--503-->\"
ServerTokens Full
ServerSignature Off
SecServerSignature \"Apache/2.4.41\"
" > /tmp/apache.conf
	echo -en "
SSLEngine On
SSLProtocol all -SSLv2 -SSLv3 -TLSv1 -TLSv1.1
SSLCipherSuite ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
SSLHonorCipherOrder Off
SSLSessionTickets Off
SSLOptions +StrictRequire
LogFormat \"%h %l %u %t \\\"%r\\\" %>s %b \\\"%{Referer}i\\\" \\\"%{User-agent}i\\\"\" vhost_combined
LogFormat \"%v %h %l %u %t \\\"%r\\\" %>s %b\" vhost_common
" > /tmp/apache-ssl.conf
	}

apache_ssl_well_known () {
	sub_domain=$2
	if [ "$sub_domain" == "" ]
		then
			sub_domain=$1
		fi
	if [ -f $APACHE_BOT_CERTIFICATE ]
		then
			if [ -f /var/www/$1/ssl/certificate/$sub_domain/key.pem ]
				then
					echo 2 | sudo -S certbot certonly --agree-tos --email certbot@netizen.ninja --webroot -w /var/www/$1/ssl -d $sub_domain
					cp /etc/letsencrypt/live/$sub_domain/fullchain.pem /var/www/$1/ssl/certificate/$sub_domain/chain.pem
					cp /etc/letsencrypt/live/$sub_domain/privkey.pem /var/www/$1/ssl/certificate/$sub_domain/key.pem
			else
				mkdir /var/www/$1/ssl/certificate/$sub_domain
				certbot certonly --agree-tos --email certbot@netizen.ninja --webroot -w /var/www/$1/ssl -d $sub_domain
				cp /etc/letsencrypt/live/$sub_domain/fullchain.pem /var/www/$1/ssl/certificate/$sub_domain/chain.pem
				cp /etc/letsencrypt/live/$sub_domain/privkey.pem /var/www/$1/ssl/certificate/$sub_domain/key.pem
				fi
	else
		touch $APACHE_BOT_CERTIFICATE
		mkdir /var/www/$1/ssl/certificate/$sub_domain
		echo N | sudo -S certbot certonly --agree-tos --email certbot@netizen.ninja --webroot -w /var/www/$1/ssl -d $sub_domain
		cp /etc/letsencrypt/live/$sub_domain/fullchain.pem /var/www/$1/ssl/certificate/$sub_domain/chain.pem
		cp /etc/letsencrypt/live/$sub_domain/privkey.pem /var/www/$1/ssl/certificate/$sub_domain/key.pem
		fi
	}

apache_ssl_dns () {
	certbot certonly --agree-tos --manual --preferred-challenges=dns --email certbot@netizen.ninja --server https://acme-v02.api.letsencrypt.org/directory -d *.$1
	}

# SSLEngine On
# SSLProtocol all -SSLv2 -SSLv3 -TLSv1 -TLSv1.1
# SSLCipherSuite ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
# SSLHonorCipherOrder Off
# SSLSessionTickets Off
# SSLOptions +StrictRequire
# LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\"" vhost_combined
# LogFormat "%v %h %l %u %t \"%r\" %>s %b" vhost_common

if [ "$1" == "--help" ]
	then
		apache_help
elif [ "$1" == "configure" ]
	then
		apache_generate_file_configuration
		apache_generate_commit --configuration
		apache_restart
elif [ "$1" == "start" ] && [ "$2" == "" ]
	then
		apache_start
elif [ "$1" == "stop" ]
	then
		apache_stop
elif [ "$1" == "restart" ]
	then
		apache_restart
elif [ "$1" == "reload" ]
	then
		apache_reload
elif [ "$1" == "plugin" ] && [ "$2" == "start" ] && [ "$3" == "--all" ]
	then
		apache_plugin_start --all
		apache_reload
elif [ "$1" == "plugin" ] && [ "$2" == "start" ]
	then
		apache_plugin_start $3
		apache_reload
elif [ "$1" == "plugin" ] && [ "$2" == "stop" ] && [ "$3" == "--all" ]
	then
		apache_plugin_stop --all
		apache_reload
elif [ "$1" == "plugin" ] && [ "$2" == "stop" ]
	then
		apache_plugin_stop $3
		apache_reload
elif [ "$1" == "plugin" ]
	then
		apache_plugin
elif [ "$1" == "site" ] && [ "$2" == "start" ]
	then
		apache_site_start $3
		apache_reload
elif [ "$1" == "site" ] && [ "$2" == "stop" ]
	then
		apache_site_stop $3
		apache_reload
elif [ "$1" == "site" ] && [ "$2" == "install" ] && [ "$3" == "000-default" ]
	then
		apache_site_stop $3
		apache_generate_file_index $3 127.0.0.1
		apache_generate_commit $3
		apache_site_start $3
		apache_reload
elif [ "$1" == "site" ] && [ "$2" == "install" ]
	then
		apache_site_stop $3
		apache_generate_file_config $3
		apache_generate_commit $3
		apache_site_start $3
		apache_reload
elif [ "$1" == "ssl" ] && [ "$2" == "well-known" ]
	then
		apache_ssl_well_known $3 $4
		apache_reload
else
	apache --help
	fi
