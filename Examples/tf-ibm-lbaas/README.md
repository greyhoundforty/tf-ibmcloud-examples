<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [LBaaS Terraform Example](#lbaas-terraform-example)
- [Pre-Requisites](#pre-requisites)
- [Updating the `main.tf` file](#updating-the-maintf-file)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## LBaaS Terraform Example

This example shows how to deploy 4 private network Virtual Guests running Apache and then create an [IBM Public Load Balancer](https://www.ibm.com/blogs/bluemix/2017/09/ibm-cloud-bluemix-load-balancer/) and bind the 4 VSIs to the Load Balancer.

## Pre-Requisites

 - An IBM Cloud Server (Bare metal or Virtual) with [Terraform](https://www.terraform.io/downloads.html) installed.
 - The sshkey of the server you will be running this on [added to the customer portal](http://knowledgelayer.softlayer.com/procedure/add-ssh-key).
 - [The IBM Cloud Terraform plugin installed](https://ibm-bluemix.github.io/tf-ibm-docs/index.html). The LBaaS offering requires [v0.5.0](https://github.com/IBM-Bluemix/terraform-provider-ibm/releases/tag/v0.5.0) of the IBM Cloud provider plugin
 - Your SoftLayer username and API Key exported as environmental varables.

```
export TF_VAR_slusername="YOUR_SOFTLAYER_USERNAME"
export TF_VAR_slapikey="YOUR_SOFTLAYER_API_KEY"
```

## Updating the `main.tf` file
You will need to update the following items in the `main.tf` file before you attempt to use it:

- Line 9: Domain name
- Line 33: Private Vlan
- Line 38: Domain name for Virtual Guests
- Line 52: The label of the SSH for the server you will be deploying from. 
- Line 85: The Subnet ID to bind the Load Balancer to. 

