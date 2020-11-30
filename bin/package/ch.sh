#!/bin/bash

if [ "$1" == "--install" ]
	then
		echo ""
elif [ "$1" == "owner" ]
	then
		if [ "$2" == "" ]
			then
				sudo chown -R $(whoami) ~/Documents
				sudo chown -R $(whoami) ~/Music
				sudo chown -R $(whoami) ~/Pictures
				sudo chown -R $(whoami) ~/Videos
				sudo chown -R $(whoami) ~/HT.doc
				sudo chown -R $(whoami) ~/Program\ File
				sudo chgrp -R $(whoami) ~/Documents
				sudo chgrp -R $(whoami) ~/Music
				sudo chgrp -R $(whoami) ~/Pictures
				sudo chgrp -R $(whoami) ~/Videos
				sudo chgrp -R $(whoami) ~/HT.doc
				sudo chgrp -R $(whoami) ~/Program\ File
		else
			sudo chown -R $(whoami) $2
			sudo chgrp -R $(whoami) $2
			fi
elif [ "$1" == "mode" ]
	then
		if [ "$2" == "" ]
			then
				sudo find ~/Documents -type d -print0 | xargs -0 chmod 755
				sudo find ~/Documents -type f \( -path "*" \) -prune -a \( ! -path "*/SSH-Key/*" \) -print0 | xargs -0 chmod 644
				sudo find ~/Music -type d -print0 | xargs -0 chmod 755
				sudo find ~/Music -type f -print0 | xargs -0 chmod 644
				sudo find ~/Pictures -type d -print0 | xargs -0 chmod 755
				sudo find ~/Pictures -type f -print0 | xargs -0 chmod 644
				sudo find ~/Videos -type d -print0 | xargs -0 chmod 755
				sudo find ~/Videos -type f -print0 | xargs -0 chmod 644
				sudo find ~/HT.doc -type d -print0 | xargs -0 chmod 755
				sudo find ~/HT.doc -type f \( -path "*" \) -prune -a \( ! -path "*/.git/*" ! -path "*/.bin/*" ! -path "*/bin/*" ! -path "*/node_modules/*" ! -path "*/node_packages/*" \) -print0 | xargs -0 chmod 644
				sudo find ~/HT.doc -name "*.sh" -type f -exec chmod +x {} \;
				sudo find ~/HT.doc -name "*.deb" -type f -exec chmod +x {} \;
				sudo find ~/HT.doc -name "*.exe" -type f -exec chmod +x {} \;
				sudo find ~/Program\ File -type d -print0 | xargs -0 chmod 755
				sudo find ~/Program\ File -type f -print0 | xargs -0 chmod 644
				sudo find ~/Program\ File -name "*.sh" -type f -exec chmod +x {} \;
				sudo find ~/Program\ File -name "*.deb" -type f -exec chmod +x {} \;
				sudo find ~/Program\ File -name "*.exe" -type f -exec chmod +x {} \;
		else
			sudo find $2 -type d -print0 | xargs -0 chmod 755
			sudo find $2 -type f \( -path "*" \) -prune -a \( ! -path "*/.git/*" ! -path "*/.bin/*" ! -path "*/bin/*" \) -print0 | xargs -0 chmod 644
			sudo find $2 -name "*.sh" -type f -exec chmod +x {} \;
			sudo find $2 -name "*.deb" -type f -exec chmod +x {} \;
			sudo find $2 -name "*.exe" -type f -exec chmod +x {} \;
		fi
else
	echo "ch [owner | mode] path"
fi
