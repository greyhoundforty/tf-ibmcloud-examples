##############################################################################
# Variables
##############################################################################
# Required for the IBM Cloud provider for Bluemix resources
variable slusername {}
variable slapikey {}
variable bxapikey {}
##############################################################################
# Configures the IBM Cloud provider
# https://ibm-bluemix.github.io/tf-ibm-docs/
##############################################################################
# Configure the IBM Cloud Provider
provider "ibm" {
  bluemix_api_key    = "${var.bxapikey}"
  softlayer_username = "${var.slusername}"
  softlayer_api_key  = "${var.slapikey}"
}

data "ibm_compute_ssh_key" "terra" {
    label = "terra"
}


resource "ibm_compute_vm_instance" "host1" {
    hostname = "host1"
    domain = "cde.services"
    os_reference_code = "UBUNTU_LATEST_64"
    datacenter = "wdc04"
    network_speed = 1000
    hourly_billing = true
    private_network_only = true 
    cores = 2
    memory = 4096
    disks = [100]
    local_disk = false
    private_vlan_id = 2161139
    ssh_key_ids = ["${data.ibm_compute_ssh_key.terra.id}"]
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

resource "ibm_compute_vm_instance" "host2" {
    hostname = "host2"
    domain = "cde.services"
    os_reference_code = "UBUNTU_LATEST_64"
    datacenter = "wdc04"
    network_speed = 1000
    hourly_billing = true
    private_network_only = true 
    cores = 2
    memory = 4096
    disks = [100]
    local_disk = false
    private_vlan_id = 2161139
    ssh_key_ids = ["${data.ibm_compute_ssh_key.terra.id}"]
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

resource "ibm_compute_vm_instance" "host3" {
    hostname = "host3"
    domain = "cde.services"
    os_reference_code = "UBUNTU_LATEST_64"
    datacenter = "wdc04"
    network_speed = 1000
    hourly_billing = true
    private_network_only = true 
    cores = 2
    memory = 4096
    disks = [100]
    local_disk = false
    private_vlan_id = 2161139
    ssh_key_ids = ["${data.ibm_compute_ssh_key.terra.id}"]
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

resource "ibm_compute_vm_instance" "host4" {
    hostname = "host4"
    domain = "cde.services"
    os_reference_code = "UBUNTU_LATEST_64"
    datacenter = "wdc04"
    network_speed = 1000
    hourly_billing = true
    private_network_only = true 
    cores = 2
    memory = 4096
    disks = [100]
    local_disk = false
    private_vlan_id = 2161139 
    ssh_key_ids = ["${data.ibm_compute_ssh_key.terra.id}"]
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
  description = "Ryan T testing schematics with lbaas"
  subnets     = [1362063]
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
      "private_ip_address" = "${ibm_compute_vm_instance.host1.ipv4_address_private}"
    },
    {
      "private_ip_address" = "${ibm_compute_vm_instance.host2.ipv4_address_private}"
    },
    {
      "private_ip_address" = "${ibm_compute_vm_instance.host3.ipv4_address_private}"
    },
    {
      "private_ip_address" = "${ibm_compute_vm_instance.host4.ipv4_address_private}"
    },
  ]
}

output "lb_id" {
    value = ["${ibm_lbaas.lbaas.vip}"]
}
