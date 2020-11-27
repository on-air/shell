#!/bin/bash

GIT_URL="https://raw.githubusercontent.com"
GIT_BRANCH="master"

file_delete () {
	if [ -f $1 ]
		then
			rm $1
		fi
	}

if [ "$1" != "" ] && [ "$2" != "" ] && [ "$3" != "" ]
	then
		if [ "$4" != "" ]
			then
				GIT_BRANCH=$4
			fi
		file_delete $3
		wget $GIT_URL/$1/$2/$GIT_BRANCH/$3
	fi
