#!/bin/bash

nginx_dir="/etc/nginx"
nginx_dir_site_availanle="$nginx_dir/sites-available"
nginx_dir_site_enabled="$nginx_dir/sites-enabled"
nginx_file_configuration="$nginx_dir/nginx.conf"
nginx_bot_certificate="$nginx_dir/certbot"

nginx_help () {
	echo "Engine-X SHELL"
	echo "ng configure"
	echo "ng start"
	echo "ng stop"
	echo "ng restart"
	echo "ng reload"
	echo "ng plugin [start | stop] --all"
	echo "ng plugin [start | stop] [name]"
	echo "ng site install [name | 000-default]"
	}

nginx_start () {
	systemctl start nginx
	}

nginx_stop () {
	systemctl stop nginx
	}

nginx_restart () {
	systemctl restart nginx
	}

nginx_reload () {
	systemctl reload nginx
	}

nginx_plugin () {
	echo ""
	}

nginx_plugin_start () {
	echo ""
	}

nginx_plugin_stop () {
	echo ""
	}

nginx_site_start () {
	if [ "$1" == "" ]
		then
			ls -la $nginx_dir_site_availanle/
	elif [ "$1" == "--all" ]
		then
			ln -s $nginx_dir_site_availanle/* $nginx_dir_site_enabled/
	else
		ln -s $nginx_dir_site_availanle/$1 $nginx_dir_site_enabled/
		if [ -f $nginx_dir_site_availanle/ssl.$1 ]
			then
				ln -s $nginx_dir_site_availanle/ssl.$1 $nginx_dir_site_enabled/
				fi
		fi
	}

nginx_site_stop () {
	if [ "$1" == "" ]
		then
			ls -la $nginx_dir_site_enabled/
	elif [ "$1" == "--all" ]
		then
			rm -rf $nginx_dir_site_enabled/*
	else
		if [ -f $nginx_dir_site_enabled/$1 ]
			then
				rm $nginx_dir_site_enabled/$1
				fi
		if [ -f $nginx_dir_site_enabled/ssl.$1 ]
			then
				rm $nginx_dir_site_enabled/ssl.$1
				fi
		fi
	}

nginx_generate_commit () {
	if [ "$1" == "--configuration" ]
		then
			cp /tmp/nginx.conf $nginx_dir/nginx.conf
			rm -rf $nginx_dir_site_availanle/*
			rm -rf $nginx_dir_site_enabled/*
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
	elif [ "$1" == "--ssl" ]
		cp /tmp/v-host-ssl-\($2\).conf $nginx_dir_site_availanle/ssl.$2
		fi
	else
		cp /tmp/v-host-\($1\).conf $nginx_dir_site_availanle/$1
		rm -rf /var/log/www/$1
		mkdir /var/log/www/$1
		rm -rf /var/www/$1
		mkdir /var/www/$1
		mkdir /var/www/$1/public
		mkdir /var/www/$1/public/static
		mkdir /var/www/$1/ssl
		mkdir /var/www/$1/ssl/.well-known
		mkdir /var/www/$1/ssl/.well-known/acme-chalenge
		mkdir /var/www/$1/ssl/certificate
		fi
	}

nginx_generate_site_default () {
	s_name=$2
	if [ "$2" == "" ]
		then
			s_name="localhost"
		fi
	echo -en "server {
	listen 80;
	index index.html;
	root /var/www/$1/public;
	server_name $s_name;
	location / {
		proxy_pass http://localhost:3000/;
		proxy_http_version 1.1;
		proxy_set_header Upgrade \$http_upgrade;
		proxy_set_header Connection 'upgrade';
		proxy_set_header Host \$host;
		proxy_cache_bypass \$http_upgrade;
		}
	location /static/ {
		try_files \$uri \$uri/ =404;
		}
	location /favicon.ico {
		try_files \$uri \$uri/ =404;
		}
	}" > /tmp/v-host-\($1\).conf
	}

nginx_generate_site () {
	echo -en "server {
	listen 80;
	access_log /var/log/www/$1/access.log;
	error_log /var/log/www/$1/error.log;
	index index.html;
	root /var/www/$1/public;
	server_name $1 www.$1 *.$1;
	location / {
		proxy_pass http://localhost:3000/;
		proxy_http_version 1.1;
		proxy_set_header Upgrade \$http_upgrade;
		proxy_set_header Connection 'upgrade';
		proxy_set_header Host \$host;
		proxy_cache_bypass \$http_upgrade;
		}
	location /static/ {
		try_files \$uri \$uri/ =404;
		}
	location /favicon.ico {
		try_files \$uri \$uri/ =404;
		}
	}" > /tmp/v-host-\($1\).conf
	}

nginx_generate_site_ssl () {
	echo -en "server {
	listen 80;
	server_name $1 www.$1 *.$1;
	return 301 https://\$host\$request_uri;
	}

server {
	listen 443 ssl;
	ssl_certificate /var/www/$1/ssl/certificate/$1/chain.pem;
	ssl_certificate_key /var/www/$1/ssl/certificate/$1/key.pem;
	# ssl_certificate /etc/letsencrypt/live/$1/fullchain.pem;
	# ssl_certificate_key /etc/letsencrypt/live/$1/privkey.pem;
	access_log /var/log/www/$1/access.log;
	error_log /var/log/www/$1/error.log;
	index index.html;
	root /var/www/$1/public;
	server_name $1;
	location / {
		proxy_pass http://localhost:3000/;
		proxy_http_version 1.1;
		proxy_set_header Upgrade \$http_upgrade;
		proxy_set_header Connection 'upgrade';
		proxy_set_header Host \$host;
		proxy_cache_bypass \$http_upgrade;
		}
	location /static/ {
		try_files \$uri \$uri/ =404;
		}
	location /favicon.ico {
		try_files \$uri \$uri/ =404;
		}
	}

server {
	listen 443 ssl;
	ssl_certificate /var/www/$1/ssl/certificate/chain.pem;
	ssl_certificate_key /var/www/$1/ssl/certificate/key.pem;
	# ssl_certificate /etc/letsencrypt/live/$1-0001/fullchain.pem;
	# ssl_certificate_key /etc/letsencrypt/live/$1-0001/privkey.pem;
	access_log /var/log/www/$1/access.log;
	error_log /var/log/www/$1/error.log;
	index index.html;
	root /var/www/$1/public;
	server_name *.$1;
	location / {
		proxy_pass http://localhost:3000/;
		proxy_http_version 1.1;
		proxy_set_header Upgrade \$http_upgrade;
		proxy_set_header Connection 'upgrade';
		proxy_set_header Host \$host;
		proxy_cache_bypass \$http_upgrade;
		}
	location /static/ {
		try_files \$uri \$uri/ =404;
		}
	location /favicon.ico {
		try_files \$uri \$uri/ =404;
		}
	}" > /tmp/v-host-ssl-\($1\).conf
	}

nginx_generate_configuration () {
	echo -en "user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
	worker_connections 768;
	# multi_accept on;
	}

http {
	sendfile on;
	client_max_body_size 100M;
	tcp_nopush on;
	tcp_nodelay on;
	keepalive_timeout 65;
	types_hash_max_size 2048;
	more_set_headers \"Server: Netizen\";
	server_tokens off;
	server_names_hash_bucket_size 64;
	include /etc/nginx/mime.types;
	default_type application/octet-stream;
	ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
	ssl_prefer_server_ciphers on;
	gzip on;
	# access_log /var/log/nginx/access.log;
	# error_log /var/log/nginx/error.log;
	server {
		listen 80;
		listen [::]:80;
		server_name _;
		return 444;
		}
	include /etc/nginx/conf.d/*.conf;
	include /etc/nginx/sites-enabled/*;
	}" > /tmp/nginx.conf
	}

nginx_ssl_well_known () {
	sub_domain=$2
	if [ "$sub_domain" == "" ]
		then
			sub_domain=$1
		fi
	if [ -f $nginx_bot_certificate ]
		then
			if [ -d /var/www/$1/ssl/certificate/$sub_domain ]
				then
					echo 2 | sudo -S certbot certonly --agree-tos --non-interactive --force-interactive --email certbot@netizen.ninja --webroot -w /var/www/$1/ssl -d $sub_domain
					cp /etc/letsencrypt/live/$sub_domain/fullchain.pem /var/www/$1/ssl/certificate/$sub_domain/chain.pem
					cp /etc/letsencrypt/live/$sub_domain/privkey.pem /var/www/$1/ssl/certificate/$sub_domain/key.pem
			else
				mkdir /var/www/$1/ssl/certificate/$sub_domain
				certbot certonly --agree-tos --non-interactive --force-interactive --email certbot@netizen.ninja --webroot -w /var/www/$1/ssl -d $sub_domain
				cp /etc/letsencrypt/live/$sub_domain/fullchain.pem /var/www/$1/ssl/certificate/$sub_domain/chain.pem
				cp /etc/letsencrypt/live/$sub_domain/privkey.pem /var/www/$1/ssl/certificate/$sub_domain/key.pem
				fi
	else
		touch $nginx_bot_certificate
		mkdir /var/www/$1/ssl/certificate/$sub_domain
		echo N | sudo -S certbot certonly --agree-tos --non-interactive --force-interactive --email certbot@netizen.ninja --webroot -w /var/www/$1/ssl -d $sub_domain
		cp /etc/letsencrypt/live/$sub_domain/fullchain.pem /var/www/$1/ssl/certificate/$sub_domain/chain.pem
		cp /etc/letsencrypt/live/$sub_domain/privkey.pem /var/www/$1/ssl/certificate/$sub_domain/key.pem
		fi
	}

nginx_ssl_wc () {
	certbot certonly --agree-tos --manual --preferred-challenges=dns --email certbot@netizen.ninja --server https://acme-v02.api.letsencrypt.org/directory -d *.$1
	cp /etc/letsencrypt/live/$1-0001/fullchain.pem /var/www/$1/ssl/certificate/chain.pem
	cp /etc/letsencrypt/live/$1-0001/privkey.pem /var/www/$1/ssl/certificate/key.pem
	}

if [ "$1" == "--help" ]
	then
		nginx_help
elif [ "$1" == "configure" ]
	then
		nginx_generate_configuration
		nginx_generate_commit --configuration
		nginx_restart
elif [ "$1" == "enable" ]
	then
		systemctl enable nginx
elif [ "$1" == "disable" ]
	then
		systemctl disable nginx
elif [ "$1" == "start" ] && [ "$2" == "" ]
	then
		nginx_start
elif [ "$1" == "stop" ]
	then
		nginx_stop
elif [ "$1" == "restart" ]
	then
		nginx_restart
elif [ "$1" == "reload" ]
	then
		nginx_reload
elif [ "$1" == "plugin" ] && [ "$2" == "start" ]
	then
		nginx_plugin_start $3
		nginx_reload
elif [ "$1" == "plugin" ] && [ "$2" == "stop" ]
	then
		nginx_plugin_stop $3
		nginx_reload
elif [ "$1" == "plugin" ]
	then
		nginx_plugin
elif [ "$1" == "site" ] && [ "$2" == "start" ]
	then
		nginx_site_start $3
		nginx_reload
elif [ "$1" == "site" ] && [ "$2" == "stop" ]
	then
		nginx_site_stop $3
		nginx_reload
elif [ "$1" == "site" ] && [ "$2" == "install" ] && [ "$3" == "000-default" ]
	then
		nginx_site_stop $3
		nginx_generate_site_default $3 $4
		nginx_generate_commit $3
		nginx_site_start $3
		nginx_reload
elif [ "$1" == "site" ] && [ "$2" == "install" ]
	then
		nginx_site_stop $3
		nginx_generate_site $3
		nginx_generate_commit $3
		nginx_site_start $3
		nginx_reload
elif [ "$1" == "site" ] && [ "$2" == "ssl" ]
	then
		nginx_site_stop $3
		nginx_generate_site_ssl --ssl $3
		nginx_generate_commit $3
		nginx_site_start $3
		nginx_reload
elif [ "$1" == "ssl" ] && [ "$2" == "well-known" ]
	then
		nginx_ssl_well_known $3 $4
		nginx_reload
elif [ "$1" == "ssl" ] && [ "$2" == "wc" ]
	then
		nginx_ssl_wc $3
		nginx_reload
else
	nginx_help
	fi
