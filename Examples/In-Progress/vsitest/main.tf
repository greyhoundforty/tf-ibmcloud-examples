# Softlayer username
variable slusername {}

# SoftLayer API key
variable slapikey {}

# The target operating system for the web nodes
variable os {
  default = "CENTOS_6_64"
}

# The number of cores each web virtual guest will recieve
variable vm_cores {
  default = 2
}
# The amount of memory each web virtual guest will recieve
variable vm_memory {
  default = 4096
}

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

resource "ibm_compute_vm_instance" "node" {
    hostname = "tfvsitest"
    domain = "${var.domainname}"
    os_reference_code = "${var.os}"
    datacenter = "${var.datacenter}"
    network_speed = 1000
    hourly_billing = true
    private_network_only = false
    cores = "${var.vm_cores}"
    memory = "${var.vm_memory}"
    disks = [100]
    local_disk = false
    public_vlan_id = "${var.pub_vlan}"
    private_vlan_id = "${var.priv_vlan}"
    ssh_key_ids = ["${data.ibm_compute_ssh_key.sshkey.id}"]
    provisioner "file" {
    source      = "server_postinstall.sh"
    destination = "/tmp/server_postinstall.sh"
    }
    provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/server_postinstall.sh",
      "/tmp/server_postinstall.sh",
    ]
    }
}
