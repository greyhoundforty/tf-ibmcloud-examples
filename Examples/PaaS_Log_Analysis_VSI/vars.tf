# IBM Cloud PaaS API Key: 
variable ibm_bmx_api_key {}

# IBM Cloud IaaS User (aka SoftLayer Username)
variable ibm_sl_username {}

# IBM Cloud IaaS User API key (aka SoftLayer User Api Key)
variable ibm_sl_api_key {}

variable datacenter {
 default = "dal13"
}

variable os {
 default = "UBUNTU_LATEST_64"
}

variable vm_cores {
 default = 1
}

variable vm_memory {
 default = 2048
}

variable priv_vlan {
 default = 1583617
}

variable pub_vlan {
 default = 1583615
}

variable domainname {
 default = "cde.services"
}
