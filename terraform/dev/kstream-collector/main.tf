variable "AWS_REGION" {}
variable "KSTREAM_STACK" {}
variable "LAMBDA_CODE_BUCKET" {}
variable "LAMBDA_CODE_PATH" {}
variable "VPC_ID" {}
variable "ELB_SUBNETS" {}
variable "DATA_BUCKET" {}
variable "DATA_PREFIX" {}

module "kstream-collector-d" {
    source = "../../modules/kstream-collector"

    AWS_REGION = var.AWS_REGION
    KSTREAM_STACK = var.KSTREAM_STACK
    LAMBDA_CODE_BUCKET = var.LAMBDA_CODE_BUCKET
    LAMBDA_CODE_PATH = var.LAMBDA_CODE_PATH
    VPC_ID = var.VPC_ID
    ELB_SUBNETS = var.ELB_SUBNETS
    DATA_BUCKET = var.DATA_BUCKET
    DATA_PREFIX = var.DATA_PREFIX
}

output "alb_dns" {
    description = "The DNS name of the Loadbalancer."
    value       = module.kstream-collector-d.lb_dns_name
}