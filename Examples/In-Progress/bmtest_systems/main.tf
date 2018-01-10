# Softlayer username
variable slusername {}

# SoftLayer API key
variable slapikey {}

# The datacenter to deploy to
variable datacenter {
  default = "wdc07"
}

# The private vlan to deploy the virtual guests on to
variable priv_vlan {
  default = 1892939
}

variable pub_vlan {
  default = 1892917
}

# The domain name for the virtual guests
variable domainname {
  default = "cde.services"
}

##############################################################################
# Configures the IBM Cloud provider
# https://ibm-bluemix.github.io/tf-ibm-docs/
##############################################################################
# Configure the IBM Cloud Provider
provider "ibm" {
  softlayer_username = "${var.slusername}"
  softlayer_api_key  = "${var.slapikey}"
}

data "ibm_compute_ssh_key" "sshkey" {
    label = "tfdev"
}

resource "ibm_compute_bare_metal" "box1" {

# Mandatory fields
    package_key_name = "DUAL_E52600_V4_12_DRIVES"
    process_key_name = "INTEL_INTEL_XEON_E52620_V4_2_10"
    memory = 32
    os_key_name = "OS_CENTOS_6_X_64_BIT"
    hostname = "tfbmhost1"
    domain = "${var.domainname}"
    datacenter = "${var.datacenter}"
    network_speed = 1000
    public_bandwidth = 500
    disk_key_names = [ "HARD_DRIVE_800GB_SSD", "HARD_DRIVE_800GB_SSD" ]
    hourly_billing = false
    unbonded_network = false
    ssh_key_ids = ["${data.ibm_compute_ssh_key.sshkey.id}"]
    public_vlan_id = "${var.pub_vlan}"
    private_vlan_id = "${var.priv_vlan}"
    public_subnet = "169.61.93.64/28"
    private_subnet = "10.190.37.128/26"
    post_install_script_uri = "https://scripts.tinylab.info/postinstalltest.sh"
    provisioner "file" {
    source      = "server1_postinstall.sh"
    destination = "/root/server1_postinstall.sh"
    }
    provisioner "remote-exec" {
    inline = [
     "chmod +x /root/server1_postinstall.sh",
     "/root/server1_postinstall.sh",
   ]
 }

}
