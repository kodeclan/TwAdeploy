#!/bin/bash

apt install curl jq

TERRAFORM_VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r -M '.current_version') ;
echo The latest version of Terraform is $TERRAFORM_VERSION ;

TERRAFORM_API="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/index.json" ;
TERRAFORM_URL=$(curl -s ${TERRAFORM_API} | jq -r -M -c --arg os "linux" --arg arch "amd64" '.builds[] | select(.os == $os) | select(.arch == $arch) | .url') ;

curl -q ${TERRAFORM_URL} | zcat | sudo tee /usr/local/bin/terraform > /dev/null ;
sudo chmod +x /usr/local/bin/terraform ;
