terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  alias = "main"
}

provider "aws" {
  alias  = "target"
  region = var.region
  assume_role {
    role_arn     = var.aws_role_arn
    session_name = "tf_session"
  }
}

provider "databricks" {
  host = var.databricks_workspace_url
}
