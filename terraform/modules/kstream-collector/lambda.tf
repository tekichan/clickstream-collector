resource "aws_lambda_function" "ClickStreamCollector" {
    function_name = "${local.kstream_lambda_name}"
    s3_bucket = "${var.LAMBDA_CODE_BUCKET}"
    s3_key = "${var.LAMBDA_CODE_PATH}/poc-kstream-collector.zip"
    role = "${aws_iam_role.kstream_lambda.arn}"
    handler = "lambda_function.lambda_handler"
    runtime = "python3.9"
    timeout = 3
    memory_size = 128

    environment {
        variables = {
            REGION_NAME = "${var.AWS_REGION}"
            KSTREAM_FIREHOSE = "${aws_kinesis_firehose_delivery_stream.kstream.name}"
        }
    }

    tags = {
        dtap = "POC"
        application = "kstream-collector"
        stack = "${var.KSTREAM_STACK}"
    }   
}

resource "aws_lambda_permission" "ClickStreamCollector" {
    statement_id  = "ClickStreamCollectorLambdaPermission"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.ClickStreamCollector.arn
    principal     = "elasticloadbalancing.amazonaws.com"
}