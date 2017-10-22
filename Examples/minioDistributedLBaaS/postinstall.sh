#!/usr/bin/env bash

installerlog="$HOME/install.log"
touch "$installerlog"

## Update system and install btrfs tools
sys_update() {
apt-get update
apt-get upgrade -y
apt-get install -y btrfs-tools
apt-get install python-pip -y
pip install softlayer  
} >> "$installerlog" 2>&1


## Create btrfs filesystem, mount it and update fstab
setup_btrfs() {
mkfs.btrfs /dev/xvdc /dev/xvde /dev/xvdf /dev/xvdg -f

mkdir /storage 
mount /dev/xvdc /storage

btuuid=$(lsblk --fs /dev/xvdc | grep -v UUID | awk '{print $3}')

echo "UUID=$btuuid /storage   btrfs  defaults 0 0" | sudo tee --append /etc/fstab
} >> "$installerlog" 2>&1

## Mount metadata volume
mount_meta() {
mkdir $HOME/temp
mount /dev/xvdh $HOME/temp
}

setup_slcli() {
SL_USER=$(cat $HOME/temp/openstack/latest/user_data | awk '{print $5}' | cut -d '"' -f2 | cut -d '=' -f2)
SL_API=$(cat $HOME/temp/openstack/latest/user_data | awk '{print $7}' | cut -d '"' -f2 | cut -d '=' -f2)

sed -i "s/SOFTLAYER_USER/$SL_USER/g" $HOME/.softlayer
sed -i "s/SOFTLAYER_APIKEY/$SL_API/g" $HOME/.softlayer
}

grab_ips() {

hostip=$(curl -s https://api.service.softlayer.com/rest/v3/SoftLayer_Resource_Metadata/getPrimaryBackendIpAddress | cut -d '"' -f2)
n1id=$(/usr/local/bin/slcli --format raw vs list -H node1 -D cde.services -d wdc07 | awk '{print $1}')
n2id=$(/usr/local/bin/slcli --format raw vs list -H node2 -D cde.services -d wdc07 | awk '{print $1}')
n3id=$(/usr/local/bin/slcli --format raw vs list -H node3 -D cde.services -d wdc07 | awk '{print $1}')
n4id=$(/usr/local/bin/slcli --format raw vs list -H node4 -D cde.services -d wdc07 | awk '{print $1}')

n1privIP=$(/usr/local/bin/slcli call-api Virtual_Guest getPrimaryBackendIpAddress --id="$n1id")
n2privIP=$(/usr/local/bin/slcli call-api Virtual_Guest getPrimaryBackendIpAddress --id="$n2id")
n3privIP=$(/usr/local/bin/slcli call-api Virtual_Guest getPrimaryBackendIpAddress --id="$n3id")
n4privIP=$(/usr/local/bin/slcli call-api Virtual_Guest getPrimaryBackendIpAddress --id="$n4id")
}

## Install minio binary and create default files
setup_minio() { 
wget -O /usr/local/bin/minio https://dl.minio.io/server/minio/release/linux-amd64/minio
chmod +x /usr/local/bin/minio
hostip=$(curl -s https://api.service.softlayer.com/rest/v3/SoftLayer_Resource_Metadata/getPrimaryBackendIpAddress | cut -d '"' -f2)

cat <<EOT >> /etc/default/minio
# Local export path.
MINIO_VOLUMES=http://stor1/storage http://stor2/storage http://stor3/storage http://stor4/storage
MINIO_OPTS="-C /etc/minio --address $hostip:9000"

EOT

sed -i "s/stor1/$n1privIP/g" /etc/default/minio
sed -i "s/stor2/$n2privIP/g" /etc/default/minio
sed -i "s/stor3/$n3privIP/g" /etc/default/minio
sed -i "s/stor4/$n4privIP/g" /etc/default/minio

cat $HOME/temp/openstack/latest/user_data | awk '{print $1}' | cut -d '"' -f2 >> /etc/default/minio
cat $HOME/temp/openstack/latest/user_data | awk '{print $3}' | cut -d '"' -f2 >> /etc/default/minio

useradd -r minio-user -s /sbin/nologin
chown minio-user:minio-user /usr/local/bin/minio
chown minio-user:minio-user /storage

mkdir /etc/minio
chown minio-user:minio-user /etc/minio
wget -O /etc/systemd/system/minio.service https://raw.githubusercontent.com/minio/minio-service/master/linux-systemd/distributed/minio.service

systemctl enable minio.service
} >> "$installerlog" 2>&1

fix_hosts_issue() { 
sed -i "s/127.0.1.1/#127.0.1.1/g" /etc/hosts 
hostip=$(curl -s https://api.service.softlayer.com/rest/v3/SoftLayer_Resource_Metadata/getPrimaryBackendIpAddress | cut -d '"' -f2)
echo -e "$hostip\t$(hostname -f)\t$(hostname -s)" | tee -a /etc/hosts

echo -e "$n1privIP\tnode1.cde.services\tnode1" | tee -a /etc/hosts
echo -e "$n2privIP\tnode2.cde.services\tnode2" | tee -a /etc/hosts
echo -e "$n3privIP\tnode3.cde.services\tnode3" | tee -a /etc/hosts
echo -e "$n4privIP\tnode4.cde.services\tnode4" | tee -a /etc/hosts
}

sys_update 
setup_btrfs
mount_meta
setup_slcli
grab_ips
setup_minio
fix_hosts_issue

sleep 180 && shutdown -r now
