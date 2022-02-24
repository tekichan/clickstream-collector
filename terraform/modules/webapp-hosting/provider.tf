terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.2"
    }
  }
}

provider "aws" {
  region = "${local.provider.aws_region}"
  shared_credentials_files = ["${local.provider.credentials_file}"]
  profile = "${local.provider.credentials_profile}"
}