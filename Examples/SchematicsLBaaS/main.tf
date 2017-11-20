# Softlayer username
variable slusername {}

# SoftLayer API key
variable slapikey {}

# The datacenter to deploy to
variable datacenter {
  default = "dal13"
}

# The number of web nodes to deploy
variable node_count {
  default = 2
}

# The target operating system for the web nodes
variable os {
  default = "UBUNTU_LATEST_64"
}

# The number of cores each web virtual guest will recieve
variable vm_cores {
  default = 1
}
# The amount of memory each web virtual guest will recieve
variable vm_memory {
  default = 2048
}

# The private vlan to deploy the virtual guests on to 
variable priv_vlan { 
  default = 1583617
}

variable pub_vlan { 
  default = 1583615
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
    label = "tycho"
}

resource "ibm_compute_vm_instance" "node" {
    count = "${var.node_count}"
    hostname = "node${count.index+1}"
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
    source      = "postinstall.sh"
    destination = "/tmp/postinstall.sh"
    }
    provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/postinstall.sh",
      "/tmp/postinstall.sh",
    ]
    }
}

resource "ibm_lbaas" "lbaas" {
  name        = "lbaasterraform"
  description = "Testing Terraform and LBaaS"
  subnets     = [1445163]
  protocols = [
    {
      frontend_protocol     = "HTTP"
      frontend_port         = 80
      backend_protocol      = "HTTP"
      backend_port          = 80
      load_balancing_method = "round_robin"
    },
  ]

  server_instances = [
    {
      "private_ip_address" = "${ibm_compute_vm_instance.node.0.ipv4_address_private}"
    },
    {
      "private_ip_address" = "${ibm_compute_vm_instance.node.1.ipv4_address_private}"
    },
  ]
}

output "lb_id" {
    value = ["${ibm_lbaas.lbaas.vip}"]
}

output "nodes" { 
    value = ["${ibm_compute_vm_instance.node.ipv4_address_private}"]
}
