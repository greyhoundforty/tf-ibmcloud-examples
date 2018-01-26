#!/bin/bash 

update_system() {
    apt-get update
    apt-get upgrade -y 
    apt-get install ntp ntpdate -y 
    service ntp stop
    ntpdate -u 0.ubuntu.pool.ntp.org
    service ntp start
    systemctl enable ntp
    wget -O - https://downloads.opvis.bluemix.net/client/IBM_Logmet_repo_install.sh | bash
    apt-get install mt-logstash-forwarder -y
}

export_vars() {
LA_URL=$(grep ingest "/tmp/creds.txt" | awk '{print $1}' | cut -d '/' -f 3)
LA_PSWD=$(grep logging_token "/tmp/creds.txt" | awk '{print $2}' | cut -d ':' -f2)
SPC_ID=$(grep space_id "/tmp/creds.txt" | awk '{print $3}' | cut -d ':' -f2)
}

config_logstash() {
sed -i "s/INGEST_URL/$LA_URL/" /tmp/mt-lsf-config.sh
sed -i "s/LA_PASSWORD/$LA_PSWD/" /tmp/mt-lsf-config.sh
sed -i "s|SPACE_ID|$SPC_ID|g" /tmp/mt-lsf-config.sh
mv /tmp/mt-lsf-config.sh /etc/mt-logstash-forwarder/mt-lsf-config.sh
}

start_logging() {
    systemctl start mt-logstash-forwarder
    systemctl enable mt-logstash-forwarder
}

update_system
export_vars
config_logstash
start_logging

