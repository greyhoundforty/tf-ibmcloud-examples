## Deploying a distributed minio cluster with an LBaaS Frontend

This example will spin up a 4 Node Distributed Minio cluster with an [IBM Public Load Balancer](https://console.bluemix.net/docs/infrastructure/loadbalancer-service/about.html#about) in front of it to distribute the traffic. To use this example you need to have at least v0.5.0 of the [IBM Cloud Terraform Provider](https://github.com/IBM-Bluemix/terraform-provider-ibm/releases) binary installed. You will also need a `~/.terraformrc` file that points to the location of the IBM Cloud Terraform binary. In my system I put the binary at `/usr/local/bin/terraform-provider-ibm` so my `~/.terraformrc` file looks like this:

```
$ cat ~/.terraformrc
providers {
        ibm = "/usr/local/bin/terraform-provider-ibm"
}
```
With that in place you can get started:

1. Clone the repository `git clone https://github.com/greyhoundforty/tf-ibmcloud-examples.git`
2. Change to the Minio example folder `cd tf-ibmcloud-examples/Examples/minioDistributedLBaaS`
3. Run `terraform init` to set up the environment
4. You can then export your credentials in your terminal, where $VALUE is your credential.

```
export TF_VAR_slusername="$VALUE"
export TF_VAR_slapikey="$VALUE"
export TF_VAR_accesskey="$VALUE"
export TF_VAR_secretkey="$VALUE"
```
- slusername: Your SoftLayer username
- slapikey: Your SoftLayer API key
- accesskey: The access key for your minio cluster
- secretkey: the secret key for your minio cluster

## Updating the main.tf file

You will need to update the following items in the main.tf file before you attempt to use it:

Line 36: Public Vlan ID
Line 41: Private Vlan ID
Line 47: Domain name for Virtual Guests
Line 60: The label of the SSH for the server you will be deploying from.
Line 99: The Subnet ID to bind the Load Balancer to.
