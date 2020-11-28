#!/bin/bash

if [ "$1" == "configure" ]
	then
		sudo -u postgres psql -c "alter user postgres with password 'postgres';"
		sudo -u postgres psql -c "create database master;"
		sudo -u postgres psql -c "create database client;"
elif [ "$1" == "start" ]
	then
		systemctl start postgresql
else
	echo ""
	fi
