#!/bin/bash

SYS_BIN="/usr/bin"
GIT_URL="https://raw.githubusercontent.com"
SHELL_REPOSITORY="$GIT_URL/on-air/shell/master"
SHELL_REPOSITORY_PACKAGE="$SHELL_REPOSITORY/bin/package"
SHELL_VAR_VIRTUAL="virtual"
APP_REPOSITORY="https://raw.githubusercontent.com/on-air/shell/master/pool"

umask 022

download () {
	if [ "$2" == "" ]
		then
			wget $1
	else
		wget -P $1 $2
		fi
	}

apt-get () {
	apt update
	if [ "$1" != "$SHELL_VAR_VIRTUAL" ]
		then
			apt upgrade -y
		fi
	}

apt-security () {
	ufw allow ssh
	ufw allow http
	ufw allow https
	if [ "$1" != "$SHELL_VAR_VIRTUAL" ]
		then
		ufw allow 24800/tcp
		fi
	echo y | sudo -S ufw enable
	}

apt-dependencies () {
	if [ "$1" != "$SHELL_VAR_VIRTUAL" ]
		then
			apt install -y gnome-tweak-tool dconf-editor font-manager
		fi
	apt install -y git curl zip unzip gnupg nginx mysql-server postgresql postgresql-contrib mongodb net-tools fail2ban
	# apt install -y apache2 libapache2-mod-security2
	curl -sL https://deb.nodesource.com/setup_15.x | sudo -E bash -
	apt install -y nodejs
	npm install -g n
	npm install -g pm2
	if [ "$1" != "$SHELL_VAR_VIRTUAL" ]
		then
			npm install -g nodemon
			npm install -g asar
			npm install -g electron-packager
			snap install barrier
			snap install atom --classic
			snap install code --classic
			snap install android-studio --classic
			# snap install slack --classic
			snap install vlc
			# snap install obs-studio
			# snap install mysql-shell
			apt install -y wine64
			echo -en "umask 022" > ~/.bash_aliases
			echo -en "umask 022" > ~/.bash_profile
	else
		snap install core
		snap refresh core
		snap install certbot --classic
		ln -s /snap/bin/certbot /usr/bin/certbot
		snap set certbot trust-plugin-with-root=ok
		echo -en "umask 022" > /root/.bash_aliases
		echo -en "umask 022" > /root/.bash_profile
		fi
	}

apt-shell () {
	rm /tmp/ls.sh
	rm /tmp/ch.sh
	rm /tmp/dl.sh
	rm /tmp/delete.sh
	rm /tmp/backup.sh
	rm /tmp/ssh-gen.sh
	rm /tmp/git.sh
	rm /tmp/git-grab.sh
	rm /tmp/git-status.sh
	rm /tmp/git-publish.sh
	rm /tmp/apache.sh
	rm /tmp/nginx.sh
	rm /tmp/my-sql.sh
	rm /tmp/postgre-sql.sh
	rm /tmp/mongo-sql.sh
	download /tmp/ $SHELL_REPOSITORY_PACKAGE/ls.sh
	download /tmp/ $SHELL_REPOSITORY_PACKAGE/ch.sh
	download /tmp/ $SHELL_REPOSITORY_PACKAGE/dl.sh
	download /tmp/ $SHELL_REPOSITORY_PACKAGE/delete.sh
	download /tmp/ $SHELL_REPOSITORY_PACKAGE/backup.sh
	download /tmp/ $SHELL_REPOSITORY_PACKAGE/ssh-gen.sh
	download /tmp/ $SHELL_REPOSITORY_PACKAGE/git.sh
	download /tmp/ $SHELL_REPOSITORY_PACKAGE/git-grab.sh
	download /tmp/ $SHELL_REPOSITORY_PACKAGE/git-status.sh
	download /tmp/ $SHELL_REPOSITORY_PACKAGE/git-publish.sh
	download /tmp/ $SHELL_REPOSITORY_PACKAGE/apache.sh
	download /tmp/ $SHELL_REPOSITORY_PACKAGE/nginx.sh
	download /tmp/ $SHELL_REPOSITORY_PACKAGE/my-sql.sh
	download /tmp/ $SHELL_REPOSITORY_PACKAGE/postgre-sql.sh
	download /tmp/ $SHELL_REPOSITORY_PACKAGE/mongo-sql.sh
	chmod +x /tmp/ls.sh
	chmod +x /tmp/ch.sh
	chmod +x /tmp/dl.sh
	chmod +x /tmp/delete.sh
	chmod +x /tmp/backup.sh
	chmod +x /tmp/ssh-gen.sh
	chmod +x /tmp/git.sh
	chmod +x /tmp/git-grab.sh
	chmod +x /tmp/git-status.sh
	chmod +x /tmp/git-publish.sh
	chmod +x /tmp/apache.sh
	chmod +x /tmp/nginx.sh
	chmod +x /tmp/my-sql.sh
	chmod +x /tmp/postgre-sql.sh
	chmod +x /tmp/mongo-sql.sh
	cp /tmp/ls.sh $SYS_BIN/list
	cp /tmp/ch.sh $SYS_BIN/ch
	cp /tmp/dl.sh $SYS_BIN/dl
	cp /tmp/delete.sh $SYS_BIN/delete
	cp /tmp/backup.sh $SYS_BIN/backup
	cp /tmp/ssh-gen.sh $SYS_BIN/ssh-gen
	cp /tmp/git.sh $SYS_BIN/g
	cp /tmp/git-grab.sh $SYS_BIN/grab
	cp /tmp/git-status.sh $SYS_BIN/status
	cp /tmp/git-publish.sh $SYS_BIN/publish
	cp /tmp/apache.sh $SYS_BIN/apache
	cp /tmp/nginx.sh $SYS_BIN/ng
	cp /tmp/my-sql.sh $SYS_BIN/my-sql
	cp /tmp/postgre-sql.sh $SYS_BIN/postgre-sql
	cp /tmp/mongo-sql.sh $SYS_BIN/mongo-sql
	}

apt-app () {
	postgre-sql configure
	ng configure
	ng plugin start --all
	ng site install 000-default $3
	if [ "$1" != "$SHELL_VAR_VIRTUAL" ]
		then
		systemctl disable nginx
		systemctl disable postgresql
		fi
	systemctl disable mysql
	systemctl disable mongodb
	apt-application $1 $2
	}

apt-application () {
	if [ "$1" == "$SHELL_VAR_VIRTUAL" ] && [ "$2" != "" ]
		then
			rm -rf /root/app
			mkdir /root/app
			rm -rf /tmp/app
			rm /tmp/app.zip
			cd /tmp
			download /tmp/ $APP_REPOSITORY/app.zip
			unzip -P $2 app.zip
			cp -r app/* /root/app/
			cd /root/app
			pm2 stop all
			pm2 delete all
			pm2 start package.js -i 2
			pm2 startup
		fi
	}

install () {
	apt-get $1
	apt-dependencies $1
	apt-shell $1
	apt-app $1 $2 $3
	apt-security $1
	}

if [ "$1" == "install" ]
	then
		install $2 $3 $4
elif [ "$1" == "update" ]
	then
		apt-shell
elif [ "$1" == "app" ] && [ "$2" == "configure" ]
	then
		apt-application $3 $4
elif [ "$1" == "app" ] && [ "$2" == "bundle" ]
	then
		rm -rf ~/HT.doc/program/node/node_temporaries/*
		rm -rf ~/HT.doc/program/app/*
		cp -r ~/HT.doc/program/node/* ~/HT.doc/program/app/
		cd ~/HT.doc/program
		zip -r --encrypt app.zip app
		mv app.zip shell/pool/app.zip
		cd shell
		status
		publish
else
	echo ""
	fi
