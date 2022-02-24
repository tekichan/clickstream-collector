resource "aws_s3_bucket" "S3Bucket" {
    bucket = var.WEBAPP_BUCKET
    force_destroy = true
    tags = {
        stack = "${var.WEBAPP_STACK}"
    }  
}

resource "aws_s3_bucket_acl" "S3BucketAcl" {
  bucket = aws_s3_bucket.S3Bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "S3BucketWebCfg" {
  bucket = aws_s3_bucket.S3Bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_cors_configuration" "S3BucketCorsCfg" {
    bucket = aws_s3_bucket.S3Bucket.id
    cors_rule {
        allowed_headers = ["Authorization", "Content-Length"]
        allowed_methods = ["GET"]
        allowed_origins = ["*"]
        max_age_seconds = 3000
    }
}

resource "aws_s3_bucket_policy" "S3BucketPolicy" {
  bucket = aws_s3_bucket.S3Bucket.id
  policy = templatefile("${path.module}/templates/bucket-policy.json", { bucket = "${var.WEBAPP_BUCKET}" })
}

resource "aws_s3_bucket" "S3BucketLog" {
    bucket = "${var.WEBAPP_BUCKET}-log"
    tags = {
        stack = "${var.WEBAPP_STACK}"
    }  
}

resource "aws_s3_bucket_acl" "S3BucketLogAcl" {
  bucket = aws_s3_bucket.S3BucketLog.id
  acl    = "log-delivery-write"
}

output "s3_dns_name" {
    description = "The DNS name of S3 Webapp Hosting."
    value       = aws_s3_bucket.S3Bucket.bucket_regional_domain_name
}

output "s3_bucket_name" {
    description = "The bucket name of S3 Webapp Hosting."
    value       = aws_s3_bucket.S3Bucket.bucket
}