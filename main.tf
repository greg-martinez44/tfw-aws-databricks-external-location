module "aws_databricks_s3" {
  source        = "app.terraform.io/gm-practice-org/aws-databricks/s3"
  version       = "1.1.1"
  bucket_prefix = var.project_name
  tags          = var.tags
  region        = var.region
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::414351767826:role/unity-catalog-prod-UCMasterRole-14S5ZJVKOTYTL",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project_name}-storage-credential"
      ]
    }
    effect = "Allow"
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.databricks_account_id]
    }
  }
}


resource "aws_iam_role" "unity_catalog" {
  name               = "${var.project_name}-storage-credential"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "unity_policy_definition" {
  statement {
    sid = "s3_storage_access"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListObject",
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload"
    ]
    resources = [module.aws_databricks_s3.bucket_arn, "${module.aws_databricks_s3.bucket_arn}/*"]
    effect    = "Allow"
  }
  statement {
    sid       = "self_assume"
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.unity_catalog.arn]
    effect    = "Allow"
  }
  statement {
    sid = "file_events_access"
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
      module.aws_databricks_s3.bucket_arn,
      "arn:aws:sqs:*:*:csms-*",
      "arn:aws:sns:*:*:csms-*"
    ]
    effect = "Allow"
  }
  statement {
    sid = "file_event_lists"
    actions = [
      "sqs:ListQueues",
      "sqs:ListQueueTags",
      "sns:ListTopics"
    ]
    resources = ["arn:aws:sqs:*:*:csms-*", "arn:aws:sns:*:*:csms-*"]
    effect    = "Allow"
  }
  statement {
    sid = "file_event_teardown"
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

data "databricks_metastores" "all" {
  provider = databricks.mws
}

locals {
  target_metastore_id_array = [for metastore in keys(data.databricks_metastores.all.ids) : data.databricks_metastores.all.ids[metastore] if endswith(metastore, replace(var.region, "-", "_"))]
  target_metastore_id       = try(local.target_metastore_id_array[0], "0")
}


resource "databricks_storage_credential" "storage_credential" {
  provider      = databricks.mws
  name          = "sc-${var.project_name}"
  metastore_id  = local.target_metastore_id
  owner         = "martinezgregory551@gmail.com"
  force_destroy = true
  aws_iam_role {
    role_arn = aws_iam_role.unity_catalog.arn
  }
  comment = "Managed by Terraform"
}

resource "databricks_external_location" "external_location" {
  provider        = databricks.mws
  name            = "exloc-${var.project_name}"
  owner           = "martinezgregory551@gmail.com"
  url             = "s3://${module.aws_databricks_s3.bucket_name}"
  credential_name = databricks_storage_credential.storage_credential.id
  comment         = "Managed by Terraform"
}

resource "databricks_grants" "exloc_grants" {
  provider          = databricks.mws
  external_location = databricks_external_location.external_location.id
  grant {
    principal  = "martinezgregory551@gmail.com"
    privileges = ["ALL_PRIVILEGES", "MANAGE"]
  }
}
