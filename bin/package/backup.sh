#!/bin/bash

if [ "$1" == "--install" ]
	then
		echo ""
else
	if [ "$1" == "" ]
		then
			dir_backup=""
	else
		dir_backup="/$1"
		mkdir ~/Backup/$1
		fi
	ch owner
	ch mode
	cp ~/.ssh/* ~/Documents/SSH-Key
	cd ~/Documents
	zip -r Document.zip *
	mv Document.zip ~/Backup$dir_backup/Document.zip
	cd ~/Music
	zip -r Music.zip *
	mv Music.zip ~/Backup$dir_backup/Music.zip
	cd ~/Pictures
	zip -r Picture.zip *
	mv Picture.zip ~/Backup$dir_backup/Picture.zip
	cd ~/Videos
	zip -r Video.zip *
	mv Video.zip ~/Backup$dir_backup/Video.zip
	# cd ~/Game
	# zip -r Game.zip *
	# mv Game.zip ~/Backup$dir_backup/Game.zip
	cd ~/HT.doc
	zip -r HT.doc.zip *
	mv HT.doc.zip ~/Backup$dir_backup/HT.doc.zip
	cd ~/Program\ File
	zip -r Program\ File.zip *
	mv Program\ File.zip ~/Backup$dir_backup/Program\ File.zip
	fi
