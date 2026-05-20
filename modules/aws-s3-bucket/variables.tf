variable "region" {
  description = "The target AWS cloud region."
  type        = string
  default     = "us-west-2"
}

variable "bucket_prefix" {
  description = "The new bucket's prefix."
  type        = string
}

variable "force_destroy" {
  description = "Whether to force delete all objects in the bucket when the bucket's destroyed."
  type        = bool
  default     = true
}

variable "tags" {
  description = "A set of tags to add to the bucket."
  type        = map(string)
}

variable "bucket_acl" {
  description = "An S3 bucket ACL."
  type        = string
  default     = null
}

variable "bucket_sse_algorithm" {
  description = "Method for S3 bucket server-side encryption."
  type        = string
  default     = "AES256"
}

variable "bucket_versioning" {
  description = "Enable or disable versioning for objects in the S3 bucket."
  type        = string
  default     = "Disabled"
  validation {
    condition     = contains(["Enabled", "Disabled"], var.bucket_versioning)
    error_message = "Bucket versioning must be `Enabled` or `Disabled`."
  }
}

variable "principal_type" {
  description = "The type of principal to grant access to in the bucket policy."
  type        = string
  default     = "AWS"
}

variable "principal_identifiers" {
  description = "A list of principal IDs"
  type        = list(string)
  default     = null
}

variable "policy_actions" {
  description = "A list of actions to allow in the bucket policy."
  type        = list(string)
  default = [
    "s3:GetObject",
    "s3:PutObject",
    "s3:DeleteObject",
    "s3:ListBucket",
    "s3:GetBucketLocation",
    "s3:ListBucketMultipartUploads",
    "s3:ListMultipartUploadParts",
    "s3:AbortMultipartUpload"
  ]
}
