resource "aws_cloudfront_distribution" "S3WebsiteDistrib" {
    origin {
        domain_name = aws_s3_bucket.S3Bucket.bucket_regional_domain_name
        origin_id = local.s3_origin_id

        custom_origin_config {
            http_port = 80
            https_port = 443
            origin_protocol_policy = "http-only"
            origin_ssl_protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"]
        }
    }

    enabled = true
    is_ipv6_enabled = true
    comment             = "Distribution Configuration for S3 Website Enabled"
    default_root_object = "index.html"

    logging_config {
        include_cookies = false
        bucket          = aws_s3_bucket.S3BucketLog.bucket_domain_name
        prefix          = "access"
    }

    custom_error_response {
        error_caching_min_ttl = 30
        error_code = 404
        response_code = 200
        response_page_path = "/error.html"
    }

    default_cache_behavior {
        allowed_methods = ["GET", "HEAD", "OPTIONS"]
        cached_methods = ["GET", "HEAD"]
        target_origin_id = local.s3_origin_id

        forwarded_values {
            query_string = false

            cookies {
                forward = "none"
            }
        }

        viewer_protocol_policy = "allow-all"
        min_ttl                = 0
        default_ttl            = 3600
        max_ttl                = 86400
        compress = true
    }

    price_class = "PriceClass_All"

    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }

    viewer_certificate {
        cloudfront_default_certificate = true
    }

    tags = {
        stack = "${var.WEBAPP_STACK}"
    } 
}

output "cloudfront_dns_name" {
    description = "The DNS name of CloudFront"
    value       = aws_cloudfront_distribution.S3WebsiteDistrib.domain_name 
}