data "aws_caller_identity" "current" {}

resource "aws_iam_role" "unity_catalog" {
  name = "${var.project_name}-storage-credential"
  path = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = ["arn:aws:iam::414351767826:role/unity-catalog-prod-UCMasterRole-14S5ZJVKOTYTL"]
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.databricks_account_id
          }
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
        }
        Condition = {
          StringEquals = {
            "AWS:PrincipalArn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project_name}-storage-credential"
            "sts:ExternalId" = var.databricks_account_id
          }
        }
      }
    ]
  })
}

data "aws_iam_policy_document" "unity_policy_definition" {
  statement {
    sid = "s3StorageAccess"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload"
    ]
    resources = [var.bucket_arn, "${var.bucket_arn}/*"]
    effect    = "Allow"
  }
  statement {
    sid       = "selfAssume"
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.unity_catalog.arn]
    effect    = "Allow"
  }
  statement {
    sid = "fileEventsAccess"
    actions = [
      "s3:GetBucketNotification",
      "s3:PutBucketNotification",
      "sns:ListSubscriptionsByTopic",
      "sns:GetTopicAttributes",
      "sns:SetTopicAttributes",
      "sns:CreateTopic",
      "sns:TagResource",
      "sns:Publish",
      "sns:Subscribe",
      "sqs:CreateQueue",
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage",
      "sqs:SendMessage",
      "sqs:GetQueueUrl",
      "sqs:GetQueueAttributes",
      "sqs:SetQueueAttributes",
      "sqs:TagQueue",
      "sqs:ChangeMessageVisibility",
      "sqs:PurgeQueue"
    ]
    resources = [
      var.bucket_arn,
      "arn:aws:sqs:*:*:csms-*",
      "arn:aws:sns:*:*:csms-*"
    ]
    effect = "Allow"
  }
  statement {
    sid = "fileEventLists"
    actions = [
      "sqs:ListQueues",
      "sqs:ListQueueTags",
      "sns:ListTopics"
    ]
    resources = ["arn:aws:sqs:*:*:csms-*", "arn:aws:sns:*:*:csms-*"]
    effect    = "Allow"
  }
  statement {
    sid = "fileEventTeardown"
    actions = [
      "sns:Unsubscribe",
      "sns:DeleteTopic",
      "sqs:DeleteQueue"
    ]
    resources = [
      "arn:aws:sqs:*:*:csms-*",
      "arn:aws:sns:*:*:csms-*"
    ]
    effect = "Allow"
  }
}

resource "aws_iam_role_policy" "unity_policy" {
  name   = "${var.project_name}-storage-credential-policy"
  role   = aws_iam_role.unity_catalog.id
  policy = data.aws_iam_policy_document.unity_policy_definition.json
}
