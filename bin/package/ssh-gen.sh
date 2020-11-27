#!/bin/bash

dir_shell="$HOME/HT.doc/program/shell"
dir_bin="/usr/local/bin"
dir_bin_package="/usr/local/bin/node_packages"

if [ "$1" == "--install" ]
	then
		sudo cp $dir_bin_package/ssh-gen.sh $dir_bin/ssh-gen
elif [ "$1" == "" ]
	then
		ssh
elif [ "$1" == "clear" ]
	then
		rm $HOME/.ssh/known_hosts
else
	ssh-keygen -t rsa -b 4096 -C $1
	fi
