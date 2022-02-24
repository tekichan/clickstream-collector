locals {
    provider = {
        credentials_file    = "~/.aws/credentials"
        credentials_profile = "default"
        aws_region          = "${var.AWS_REGION}"
    }

    kstream_lambda_role = "poc-kstream-lambda-role"
    kstream_lambda_role_policy = "poc-kstream-lambda-role-policy"
    kstream_firehose_role = "poc-kstream-firehose-role"
    kstream_firehose_role_policy = "poc-kstream-firehose-role-policy"
    kstream_firehose_name = "KStreamFirehose"
    kstream_lambda_name = "poc-kstream-collector"
    alb_security_group = "AlbSecurityGroup"
    alb_name = "KStreamLoadBalancer"
    alb_tg_name = "KStreamTargetGroup"
}