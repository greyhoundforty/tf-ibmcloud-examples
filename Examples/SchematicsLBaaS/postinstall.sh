#!/usr/bin/env bash

installerlog="$HOME/install.log"
touch "$installerlog"

update_sys() { 
apt-get update 
apt-get upgrade -y 
apt-get install apache2 -y 
echo $(hostname -f) | tee /var/www/html/index.html
} >> "$installerlog" 2>&1