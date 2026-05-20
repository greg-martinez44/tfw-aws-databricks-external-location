module "aws_s3_bucket" {
  source  = "app.terraform.io/gm-practice-org/aws-s3/aws"
  version = "1.1.1"
  providers = {
    aws = aws.target
  }
  bucket_prefix = var.project_name
  tags          = var.tags
  bucket_acl    = "private"
}

module "aws_unity_role" {
  source = "./modules/aws-unity-role"
  providers = {
    aws = aws.target
  }
  bucket_arn            = module.aws_s3_bucket.bucket_arn
  databricks_account_id = var.databricks_account_id
  project_name          = var.project_name
  tags                  = var.tags
  depends_on            = [module.aws_s3_bucket]
}

data "databricks_group" "admin_group" {
  display_name = "account_admins"
}

resource "databricks_storage_credential" "storage_credential" {
  name          = "sc-${var.project_name}"
  owner         = data.databricks_group.admin_group.display_name
  force_destroy = true
  aws_iam_role {
    role_arn = module.aws_unity_role.role_arn
  }
  comment = "Managed by Terraform"
}

resource "databricks_grants" "sc_grants" {
  storage_credential = databricks_storage_credential.storage_credential.id
  grant {
    principal  = data.databricks_group.admin_group.display_name
    privileges = ["ALL_PRIVILEGES", "MANAGE"]
  }
}

resource "databricks_external_location" "external_location" {
  name            = "exloc-${var.project_name}"
  owner           = data.databricks_group.admin_group.display_name
  url             = "s3://${module.aws_s3_bucket.bucket_name}"
  credential_name = databricks_storage_credential.storage_credential.id
  comment         = "Managed by Terraform"
  skip_validation = true
  isolation_mode  = "ISOLATION_MODE_ISOLATED"
  depends_on      = [databricks_grants.sc_grants]
}

resource "databricks_grants" "exloc_grants" {
  external_location = databricks_external_location.external_location.id
  grant {
    principal  = data.databricks_group.admin_group.display_name
    privileges = ["ALL_PRIVILEGES", "MANAGE"]
  }
}
