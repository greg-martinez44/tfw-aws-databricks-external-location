variable "region" {
  description = "The AWS cloud region."
  type        = string
  default     = "us-west-2"
}

variable "databricks_account_url" {
  description = "The AWS Databricks account URL."
  type        = string
}

variable "databricks_account_id" {
  description = "The AWS Databricks account ID."
  type        = string
}

variable "project_name" {
  description = "The new project name."
  type        = string
}

variable "tags" {
  description = "Tags to add to each resource."
  type        = map(string)
}
