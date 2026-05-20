variable "databricks_account_id" {
  description = "The AWS Databricks account ID."
  type        = string
}

variable "project_name" {
  description = "The new project name."
  type        = string
}

variable "bucket_arn" {
  description = "The target bucket ARN."
  type        = string
}

variable "tags" {
  description = "Tags to add to new resources."
  type        = map(string)
}
