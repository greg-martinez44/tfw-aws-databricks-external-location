resource "aws_s3_bucket" "bucket" {
  bucket_prefix = "${var.bucket_prefix}-"
  region        = var.region
  force_destroy = var.force_destroy
  tags          = var.tags
}

resource "aws_s3_bucket_ownership_controls" "ownership_controls" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "acl" {
  count      = var.bucket_acl != null ? 1 : 0
  bucket     = aws_s3_bucket.bucket.id
  acl        = var.bucket_acl
  depends_on = [aws_s3_bucket_ownership_controls.ownership_controls]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption_configuration" {
  count  = var.bucket_sse_algorithm != null ? 1 : 0
  bucket = aws_s3_bucket.bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.bucket_sse_algorithm
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = var.bucket_versioning
  }
}

data "aws_caller_identity" "current" {
  count = var.bucket_acl == null ? 1 : 0
}

data "aws_iam_policy_document" "policy_document" {
  count = var.bucket_acl == null ? 1 : 0
  statement {
    principals {
      type        = coalesce(var.principal_type, "AWS")
      identifiers = coalesce(var.principal_identifiers, [data.aws_caller_identity.current[0].account_id])
    }
    actions = var.policy_actions
    resources = [
      aws_s3_bucket.bucket.arn,
      "${aws_s3_bucket.bucket.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "policy" {
  count      = var.bucket_acl == null ? 1 : 0
  bucket     = aws_s3_bucket.bucket.id
  policy     = data.aws_iam_policy_document.policy_document[0].json
  depends_on = [aws_s3_bucket_public_access_block.public_access_block]
}
