locals {
    provider = {
        credentials_file    = "~/.aws/credentials"
        credentials_profile = "default"
        aws_region          = "${var.AWS_REGION}"
    }

    s3_origin_id = "S3-${var.WEBAPP_BUCKET}"
}