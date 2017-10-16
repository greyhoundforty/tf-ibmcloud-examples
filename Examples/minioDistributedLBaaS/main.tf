##############################################################################
# Variables
##############################################################################
# Required for the IBM Cloud provider for Bluemix resources
variable bxapikey {}
variable slusername {}
variable slapikey {}

# The datacenter to deploy to
variable datacenter {
  default = "dal13"
}

# The number of web nodes to deploy
variable node_count {
  default = 4
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

# The domain name for the virtual guests
variable domainname {
  default = "cde.services"
}
##############################################################################
# Configures the IBM Cloud provider
# https://ibm-bluemix.github.io/tf-ibm-docs/
##############################################################################
provider "ibm" {
  bluemix_api_key    = "${var.bxapikey}"
  softlayer_username = "${var.slusername}"
  softlayer_api_key  = "${var.slapikey}"
}

#############################################################################
# Require terraform 0.9.3 or greater to run this template
# https://www.terraform.io/docs/configuration/terraform.html
#############################################################################
terraform {
  required_version = ">= 0.9.3"
}

# Load my laptop ssh key so that it can be assigned to the created Virtual Guests
data "ibm_compute_ssh_key" "tycho" {
    label = "tycho"
}

data "ibm_compute_ssh_key" "terra" {
    label = "terra"
}

resource "ibm_compute_vm_instance" "minio" {
    count = "${var.node_count}"
    hostname = "minio${count.index+1}"
    domain = "${var.domainname}"
    os_reference_code = "${var.os}"
    datacenter = "${var.datacenter}"
    network_speed = 1000
    hourly_billing = true
    private_network_only = true
    cores = "${var.vm_cores}"
    memory = "${var.vm_memory}"
    disks = [100, 2000, 2000, 2000, 2000]
    local_disk = false
    private_vlan_id = "${var.priv_vlan}"
    user_metadata = "{\"MINIO_ACCESS_KEY=${var.accesskey}\" : \"MINIO_SECRET_KEY=${var.secretkey}\"}"
    ssh_key_ids = ["${data.ibm_compute_ssh_key.terra.id}","${data.ibm_compute_ssh_key.tycho.id}"]
    provisioner "file" {
    source      = "postinstall.sh"
    destination = "/tmp/postinstall.sh"
    }
    provisioner "file" {
    source      = "minio"
    destination = "/usr/local/bin/minio"
    }
    provisioner "file" {
    source      = "minio.service"
    destination = "/etc/systemd/system/minio.service"
    }
    provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/postinstall.sh",
      "/tmp/postinstall.sh",
    ]
  }
}

##############################################################################
# Creating the DNS entries
# https://ibm-bluemix.github.io/tf-ibm-docs/v0.4.0/r/dns_record.html
##############################################################################

# Load the domain as `domain_id` to be used when creating the DNS records
data "ibm_dns_domain" "domain_id" {
    name = "cde.services"
}

resource "ibm_dns_record" "minio0" {
    data = "${ibm_compute_vm_instance.minio0.ipv4_address_private}"
    domain_id = "${data.ibm_dns_domain.domain_id.id}"
    host = "minio0"
    responsible_person = "rtiffany@us.ibm.com"
    ttl = 900
    type = "a"
}

resource "ibm_dns_record" "minio1" {
    data = "${ibm_compute_vm_instance.minio1.ipv4_address_private}"
    domain_id = "${data.ibm_dns_domain.domain_id.id}"
    host = "minio1"
    responsible_person = "rtiffany@us.ibm.com"
    ttl = 900
    type = "a"
}


resource "ibm_dns_record" "minio2" {
    data = "${ibm_compute_vm_instance.minio2.ipv4_address_private}"
    domain_id = "${data.ibm_dns_domain.domain_id.id}"
    host = "minio2"
    responsible_person = "rtiffany@us.ibm.com"
    ttl = 900
    type = "a"
}

resource "ibm_dns_record" "minio3" {
    data = "${ibm_compute_vm_instance.minio3.ipv4_address_private}"
    domain_id = "${data.ibm_dns_domain.domain_id.id}"
    host = "minio3"
    responsible_person = "rtiffany@us.ibm.com"
    ttl = 900
    type = "a"
}


resource "ibm_lbaas" "lbaas" {
  name        = "minioLB"
  description = "Testing Terraform, LBaaS and minio"
  subnets     = [1445163]
  protocols = [
    {
      frontend_protocol     = "TCP"
      frontend_port         = 80
      backend_protocol      = "TCP"
      backend_port          = 9000
      load_balancing_method = "round_robin"
    },
  ]

  server_instances = [
    {
      "private_ip_address" = "${ibm_compute_vm_instance.minio.0.ipv4_address_private}"
    },
    {
      "private_ip_address" = "${ibm_compute_vm_instance.minio.1.ipv4_address_private}"
    },
    {
      "private_ip_address" = "${ibm_compute_vm_instance.minio.2.ipv4_address_private}"
    },
    {
      "private_ip_address" = "${ibm_compute_vm_instance.minio.3.ipv4_address_private}"
    },
  ]
}

output "lb_id" {
    value = ["${ibm_lbaas.lbaas.vip}"]
}
