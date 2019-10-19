# GwD01

Private GwD repo number 01

Prerequisites:

1. Terraform
2. OpenSSH
3. A JSON that contains the credentials to the Google Compute Engine Service Account which can be obtained at: <https://console.cloud.google.com/apis/credentials/serviceaccountkey>
4. A project name that corresponds top a project that has been created on Google Cloud Platform

Terraform needs to fetch all the provisioners that will help carry out the necessary changes. This can be done via `terraform init`

The one-line syntax to create a new instance is as follows:

    terraform (plan|apply|delete) -var credentials=__path-to-json-file__ -var project=__project-name__

If the variables are not provided, Terraform will ask for the variables at runtime.
