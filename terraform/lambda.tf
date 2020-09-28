data "aws_caller_identity" "current" {}

resource "aws_iam_role" "iam_for_lambda" {
  name = "embulk_onetime_manage_rds"

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
}

resource "aws_lambda_function" "create_onetime_rds" {
  filename         = "lambda/create-onetime-rds.zip"
  function_name    = "create_onetime_rds"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "create-onetime-rds.handler"
  runtime          = "nodejs12.x"
  timeout          = 600
  source_code_hash = filebase64sha256("lambda/create-onetime-rds.zip")

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.lambda,
  ]

  tags = {
    Name = var.project_name
  }
}

resource "aws_lambda_function" "delete_onetime_rds" {
  filename         = "lambda/delete-onetime-rds.zip"
  function_name    = "delete_onetime_rds"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "delete-onetime-rds.handler"
  runtime          = "nodejs12.x"
  timeout          = 600
  source_code_hash = filebase64sha256("lambda/delete-onetime-rds.zip")

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.lambda,
  ]

  tags = {
    Name = var.project_name
  }
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.project_name}"
  retention_in_days = 14
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "rds:DescribeDBSnapshots",
        "rds:DescribeDBInstances",
        "rds:CreateDBSnapshot",
        "rds:RestoreDBInstanceFromDBSnapshot",
        "rds:DeleteDBSnapshot",
        "rds:DeleteDBInstance"
      ],
      "Resource": [
        "arn:aws:rds:*:${data.aws_caller_identity.current.account_id}:snapshot:*",
        "arn:aws:rds:*:${data.aws_caller_identity.current.account_id}:db:*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}
