variable "AWS_REGION" {
    description = "AWS Region Code"
    type        = string
}

variable "KSTREAM_STACK" {
    description = "The stack name of clickstream collector"
    type        = string
}

variable "LAMBDA_CODE_BUCKET" {
    description = "S3 Bucket name of Lambda codes"
    type        = string
}

variable "LAMBDA_CODE_PATH" {
    description = "S3 Path key of Lambda codes"
    type        = string
}

variable "VPC_ID" {
    description = "VPC ID of ALB"
    type        = string
}

variable "ELB_SUBNETS" {
    description = "Subnet IDs of ALB"
    type        = string
}

variable "DATA_BUCKET" {
    description = "S3 bucket name of Firehose destination"
    type        = string
}

variable "DATA_PREFIX" {
    description = "S3 Key Prefix of Firehose destination"
    type        = string
}