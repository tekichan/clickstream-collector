variable "AWS_REGION" {
    description = "AWS Region Code"
    type        = string
}

variable "WEBAPP_STACK" {
    description = "The stack name of webapp-hosting"
    type        = string
}

variable "WEBAPP_BUCKET" {
    description = "S3 Bucket name of webapp-hosting"
    type        = string
}