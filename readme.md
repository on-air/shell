```sh
#!/bin/bash

curl -sL https://raw.githubusercontent.com/on-air/shell/master/install/virtual.sh | sudo -E bash -
```

```sh
#!/bin/bash

umask 022
sudo wget -P /tmp/ https://raw.githubusercontent.com/on-air/shell/master/bin/shell.sh
sudo chmod +x /tmp/shell.sh
sudo cp /tmp/shell.sh /usr/bin/shell
sudo shell install virtual
export HOSTNAME=$(curl -s http://169.254.169.254/metadata/v1/hostname)
export PUBLIC_IPV4=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)
echo Droplet: $HOSTNAME, IP Address: $PUBLIC_IPV4 > /root/index.html
```

```sh
zip -r --encrypt file.zip path
unzip -P password file.zip
```
