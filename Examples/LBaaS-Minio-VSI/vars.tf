
# Required for the IBM Cloud provider for Bluemix resources
variable bxapikey {}
variable slusername {}
variable slapikey {}

# Needed for minio 
variable accesskey {}
variable secretkey {}

# The datacenter to deploy to
variable datacenter {
  default = "wdc07"
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

# The public vlan to deploy the virtual guests on to
variable pub_vlan {
  default = 1892917
}

# The private vlan to deploy the virtual guests on to
variable priv_vlan {
  default = 1892939
}

# The domain name for the virtual guests
variable domainname {
  default = "cde.services"
}