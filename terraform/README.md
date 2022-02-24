# Terraform Stack

This folder consists of Terraform scripts to deploy both Clickstream Collection and Webapp Hosting stacks, as the alternative of CloudFormation templates.

# Perquisite
- Follow **Perquisite** of [the master document](../README.md)
- Install [Terraform CLI](https://www.terraform.io/downloads)
- Initiate Terraform
```bash
cd dev/kstream-collector
terraform init
cd ..
cd webapp-hosting
terraform init
```

# Build and Deploy
```bash
./apply_upload_lf.sh -e ../.env
./apply_upload_fe.sh -e ../.env
```

# Destroy stacks
- Destroy the terraform stack 
```bash
./destroy_fe.sh -e ../.env
./destroy_lf.sh -e ../.env
```
