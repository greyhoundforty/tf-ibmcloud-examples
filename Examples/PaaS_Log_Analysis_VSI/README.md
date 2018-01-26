# IBM Cloud PaaS Log Analysis and VSIs

This is an example of deploying an instance of the IBM Cloud [PaaS Log Analysis Service](https://console.bluemix.net/docs/services/CloudLogAnalysis/index.html) along with a VSI that is configured to use the Log Analysis service out of the box. You will need to modify the `vars.tf` and `main.tf` file to suit your needs. This was tested using Ubuntu 16. If you are using Centos/RHEL you will also need to update the `postinstall.sh` file to match your Operating System.

## Pre-requisites
- [IBM Cloud Platform API Key](https://console.bluemix.net/docs/iam/userid_keys.html#creating-an-api-key)
- [IBM Cloud Infrastructure (SoftLayer) API key](https://console.bluemix.net/docs/containers/cs_infrastructure.html#old_account)
- Proper permissions to deploy the Log Analysis service in your Org.

## Export Username and API Keys
You need to export your Infrastructure Username and API Key as well as your Platform API key.

```
export TF_VAR_ibm_sl_api_key='YOUR SOFTLAYER API KEY'
export TF_VAR_ibm_sl_username='YOUR SOFTLAYER USERNAME'
export TF_VAR_ibm_bmx_api_key='YOUR PLATFORM API KEY'
```
