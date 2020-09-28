resource "aws_iam_role" "iam_for_sfn" {
  name = "embulk_onetime_manage_rds_step_functions"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "states.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "embulk-onetime-rds"
  role_arn = aws_iam_role.iam_for_sfn.arn

  definition = <<EOF
{
  "Comment": "Embulk onetime RDS",
  "StartAt": "CreateOnetimeRDS",
  "States": {
    "CreateOnetimeRDS": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "arn:aws:lambda:ap-northeast-1:${data.aws_caller_identity.current.account_id}:function:create_onetime_rds",
        "Payload": {
          "DBInstanceIdentifier.$": "$.DBInstanceIdentifier"
        }
      },
      "Next": "Wait"
    },
    "Wait": {
      "Type": "Wait",
      "Seconds": 10,
      "Next": "DeleteOnetimeRDS"
    },
    "DeleteOnetimeRDS": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "arn:aws:lambda:ap-northeast-1:${data.aws_caller_identity.current.account_id}:function:delete_onetime_rds",
        "Payload": {
          "Identifier.$": "$.Payload.Identifier"
        }
      },
      "End": true
    }
  }
}
EOF
}

resource "aws_iam_policy" "step_functions" {
  name        = "embulk_onetime_step_functions"
  path        = "/"
  description = "IAM policy for embulk step functions"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
          "logs:CreateLogDelivery",
          "logs:GetLogDelivery",
          "logs:UpdateLogDelivery",
          "logs:DeleteLogDelivery",
          "logs:ListLogDeliveries",
          "logs:PutResourcePolicy",
          "logs:DescribeResourcePolicies",
          "logs:DescribeLogGroups"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Resource": [
        "arn:aws:lambda:ap-northeast-1:${data.aws_caller_identity.current.account_id}:function:delete_onetime_rds:*",
        "arn:aws:lambda:ap-northeast-1:${data.aws_caller_identity.current.account_id}:function:create_onetime_rds:*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Resource": [
        "arn:aws:lambda:ap-northeast-1:${data.aws_caller_identity.current.account_id}:function:delete_onetime_rds",
        "arn:aws:lambda:ap-northeast-1:${data.aws_caller_identity.current.account_id}:function:create_onetime_rds"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "step_functions" {
  role       = aws_iam_role.iam_for_sfn.name
  policy_arn = aws_iam_policy.step_functions.arn
}
