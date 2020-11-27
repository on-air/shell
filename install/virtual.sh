#!/bin/bash

umask 022
wget -P /tmp/ https://raw.githubusercontent.com/on-air/shell/master/bin/shell.sh
chmod +x /tmp/shell.sh
cp /tmp/shell.sh /usr/bin/shell
shell install virtual
