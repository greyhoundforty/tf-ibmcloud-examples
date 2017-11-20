# Terraform and IBM Cloud examples
This repo contains some examples I have put together to use Terraform and the [IBM Cloud Terraform Provider](https://ibm-bluemix.github.io/tf-ibm-docs/index.html) plugin. Most examples are using the (at current time) latest 0.5.0 version of the provider plugin. 

## Simple web server with LBaaS
Deploys 4 private network Virtual Guests running apache as well as an [IBM Cloud Load Balancer](https://console.bluemix.net/docs/infrastructure/loadbalancer-service/basic-load-balancing.html#basic-load-balancing) to distribute the traffic between the nodes. 

## Distributed Minio cluster with LBaaS
Deploys 4 Virtual Guests running a [Distributed Minio Cluster](https://docs.minio.io/docs/distributed-minio-quickstart-guide) as well as an [IBM Cloud Load Balancer](https://console.bluemix.net/docs/infrastructure/loadbalancer-service/basic-load-balancing.html#basic-load-balancing) to distribute the traffic between the nodes. 

## Security Groups
This example creates a security group with 3 rules to allow SSH access to a new VSI from 3 different locations. Relies on the updated [v0.6.0](https://github.com/IBM-Bluemix/terraform-provider-ibm/releases/tag/v0.6.0) IBM Cloud Provider plugin. 

## more to come
