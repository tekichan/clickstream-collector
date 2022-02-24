variable "AWS_REGION" {}
variable "WEBAPP_STACK" {}
variable "WEBAPP_BUCKET" {}

module "webapp-hosting-d" {
    source = "../../modules/webapp-hosting"

    AWS_REGION = var.AWS_REGION
    WEBAPP_STACK = var.WEBAPP_STACK
    WEBAPP_BUCKET = var.WEBAPP_BUCKET
}

output "s3_bucket" {
    description = "S3 Bucket Name of Webapp Hosting"
    value       = module.webapp-hosting-d.s3_bucket_name
}

output "cf_dns_name" {
    description = "The DNS name of the CloudFront."
    value       = module.webapp-hosting-d.cloudfront_dns_name
}