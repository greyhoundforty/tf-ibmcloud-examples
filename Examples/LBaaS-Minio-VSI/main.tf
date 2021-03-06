
##############################################################################
# Configures the IBM Cloud provider
# https://ibm-bluemix.github.io/tf-ibm-docs/
##############################################################################
provider "ibm" {
  bluemix_api_key    = "${var.bxapikey}"
  softlayer_username = "${var.slusername}"
  softlayer_api_key  = "${var.slapikey}"
}

data "ibm_compute_ssh_key" "terra" {
    label = "terra"
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
    disks = [100, 2000, 2000, 2000, 2000]
    local_disk = false
    public_vlan_id = "${var.pub_vlan}"
    private_vlan_id = "${var.priv_vlan}"
    user_metadata = "{\"MINIO_ACCESS_KEY=${var.accesskey}\" : \"MINIO_SECRET_KEY=${var.secretkey}\" : \"SOFTLAYER_USERNAME=${var.slusername}\" : \"SOFTLAYER_API_KEY=${var.slapikey}\"}"
    ssh_key_ids = ["${data.ibm_compute_ssh_key.terra.id}"]
    provisioner "file" {
    source      = "softlayer"
    destination = "/root/.softlayer"
    }
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
  name        = "lbaasminio"
  description = "Testing Terraform, LBaaS and minio"
  subnets     = [1550219]
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
      "private_ip_address" = "${ibm_compute_vm_instance.node.0.ipv4_address_private}"
    },
    {
      "private_ip_address" = "${ibm_compute_vm_instance.node.1.ipv4_address_private}"
    },
    {
      "private_ip_address" = "${ibm_compute_vm_instance.node.2.ipv4_address_private}"
    },
    {
      "private_ip_address" = "${ibm_compute_vm_instance.node.3.ipv4_address_private}"
    },
  ]
}

output "lb_id" {
    value = ["${ibm_lbaas.lbaas.vip}"]
}
