variable "vpc_id" {}
provider "aws" {
  region = "us-east-1"
}

resource "aws_guardduty_detector" "main" {
  enable = true
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "incident-response-logs-${random_id.suffix.hex}"
}

resource "aws_cloudtrail" "main" {
  name                          = "incident-response-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  include_global_service_events = true
  is_multi_region_trail         = true
}

resource "aws_s3_bucket_policy" "cloudtrail_policy" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck",
        Effect = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action   = "s3:GetBucketAcl",
        Resource = aws_s3_bucket.cloudtrail_logs.arn
      },
      {
        Sid    = "AWSCloudTrailWrite",
        Effect = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action   = "s3:PutObject",
        Resource = "${aws_s3_bucket.cloudtrail_logs.arn}/*",
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "lambda_role" {
  name = "incident-response-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:ModifyInstanceAttribute",
          "ec2:DescribeInstances"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_security_group" "quarantine" {
  name        = "incident-response-quarantine-sg"
  description = "Isolation security group"
  vpc_id      = var.vpc_id
}

resource "aws_lambda_function" "isolate" {
  function_name = "incident-response-isolate"
  runtime       = "python3.11"
  handler       = "handler.lambda_handler"
  role          = aws_iam_role.lambda_role.arn

  filename         = "lambda/lambda.zip"
  source_code_hash = filebase64sha256("lambda/lambda.zip")

  environment {
    variables = {
      QUARANTINE_SG = aws_security_group.quarantine.id
    }
  }
}


resource "aws_cloudwatch_event_rule" "guardduty_rule" {
  name        = "incident-response-guardduty-rule"
  description = "Trigger Lambda on GuardDuty findings"

  event_pattern = jsonencode({
    source = ["aws.guardduty"]
  })
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.guardduty_rule.name
  target_id = "lambda"
  arn       = aws_lambda_function.isolate.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.isolate.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.guardduty_rule.arn
}
