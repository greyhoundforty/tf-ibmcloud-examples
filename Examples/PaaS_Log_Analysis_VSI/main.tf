# Configure the IBM Cloud Provider
provider "ibm" {
  bluemix_api_key    = "${var.ibm_bmx_api_key}"
  softlayer_username = "${var.ibm_sl_username}"
  softlayer_api_key  = "${var.ibm_sl_api_key}"
}

data "ibm_org" "orgData" {
  org = "CDE TEAM"
}

data "ibm_account" "accountData" {
  org_guid = "${data.ibm_org.orgData.id}"
}

data "ibm_space" "spaceData" {
  space = "coolkids"
  org   = "CDE TEAM"
}

data "ibm_compute_ssh_key" "sshkey" {
    label = "ryan_ganymede"
}

resource "ibm_service_instance" "log_service" {
  name       = "tfloggylog"
  space_guid = "${data.ibm_space.spaceData.id}"
  service    = "ibmLogAnalysis"
  plan       = "premiumsearch5"
}

resource "ibm_service_key" "serviceKey" {
  name                  = "tfloggylogkey"
  service_instance_guid = "${ibm_service_instance.log_service.id}"
  provisioner "local-exec" {
    command = "echo ${jsonencode(ibm_service_key.serviceKey.credentials)} >> ${ibm_service_instance.log_service.id}_creds.txt"
  }
}

resource "ibm_compute_vm_instance" "node" {
    depends_on = ["ibm_service_instance.log_service"]
    hostname = "tflognode"
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
    private_vlan_id = "${var.priv_vlan}"
    public_vlan_id = "${var.pub_vlan}"
    ssh_key_ids = ["${data.ibm_compute_ssh_key.sshkey.id}"]

    provisioner "file" {
      source      = "mt-lsf-config.sh"
      destination = "/tmp/mt-lsf-config.sh"
    }

    provisioner "file" {
      source      = "${ibm_service_instance.log_service.id}_creds.txt"
      destination = "/tmp/creds.txt"
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

output "nodeip" {
  value = "${ibm_compute_vm_instance.node.ipv4_address}"
}