resource "aws_iam_role" "kstream_lambda" {
    name = "${local.kstream_lambda_role}"
 
    assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF

    managed_policy_arns  = [
        "arn:aws:iam::aws:policy/AWSLambdaExecute"
        , "arn:aws:iam::aws:policy/AmazonS3FullAccess"
        , "arn:aws:iam::aws:policy/AmazonKinesisFullAccess"
    ]
}

resource "aws_iam_policy" "kstream_lambda" {
    name        = "${local.kstream_lambda_role_policy}"
    description = "Role Policy for Clickstream Collection Lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "firehose:DeleteDeliveryStream",
        "firehose:PutRecord",
        "firehose:PutRecordBatch",
        "firehose:UpdateDestination"
      ],
      "Effect": "Allow",
      "Resource": "${aws_kinesis_firehose_delivery_stream.kstream.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "kstream_lambda" {
  role       = aws_iam_role.kstream_lambda.name
  policy_arn = aws_iam_policy.kstream_lambda.arn
}

resource "aws_iam_role" "kstream_firehose" {
    name = "${local.kstream_firehose_role}"
 
    assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "firehose.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_policy" "kstream_firehose" {
    name        = "${local.kstream_firehose_role_policy}"
    description = "Role Policy for Clickstream Collection Firehose"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:AbortMultipartUpload",
        "s3:GetBucketLocation",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.DATA_BUCKET}*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "kstream_firehose" {
  role       = aws_iam_role.kstream_firehose.name
  policy_arn = aws_iam_policy.kstream_firehose.arn
}
