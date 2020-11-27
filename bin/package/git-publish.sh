#!/bin/bash

flag_name=""
flag_branch="master"
flag_force=""
flag_all=""
flag_extension=""

i=1
x=$#
arg=()
while [ $i -le $x ]
	do
		if [ "$1" == "--name" ]
			then
				flag_name=$2
			fi
		if [ "$1" == "--branch" ]
			then
				flag_branch=$2
			fi
		if [ "$1" == "--force" ]
			then
				flag_force="force"
			fi
		if [ "$1" == "--all" ]
			then
				flag_all="all"
			fi
		if [ "$1" == "--extension" ]
			then
				flag_extension=$2
			fi
		arg[$i]=$1
		i=$((i + 1))
		shift 1
	done

a=${arg[1]}
b=${arg[2]}
c=${arg[3]}
d=${arg[4]}
e=${arg[5]}

if [ "$a" == "" ]
	then
		if [ "$flag_force" == "force" ]
			then
				git add --all
				git commit -m "."
				git push -f origin $flag_branch
		else
			git add --all
			git commit -m "."
			git push origin $flag_branch
			fi
elif [ "$a" == "to" ]
	then
		if [ "$flag_force" == "force" ]
			then
				git add --all
				git commit -m "."
				git push -f origin $b
		else
			git add --all
			git commit -m "."
			git push origin $b
			fi
else
	echo ""
	fi
