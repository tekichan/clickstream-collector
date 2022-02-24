resource "aws_kinesis_firehose_delivery_stream" "kstream" {
  name        = "${local.kstream_firehose_name}"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.kstream_firehose.arn
    bucket_arn = "arn:aws:s3:::${var.DATA_BUCKET}"
    prefix = var.DATA_PREFIX
    buffer_size = 50
    buffer_interval = 60
    compression_format = "UNCOMPRESSED"
  }
}
