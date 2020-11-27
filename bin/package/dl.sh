#!/bin/bash

if [ "$2" == "" ]
	then
		wget $1
else
	wget -P $1 $2
	fi
