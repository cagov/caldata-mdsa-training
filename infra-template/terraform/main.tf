############################
#        Terraform         #
############################

terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 1.0"
    }
  }
  required_version = ">= 1.0"

  # Training uses local state by default so learners can provision from a clean
  # repository with no cloud prerequisites. State is written to terraform.tfstate
  # in this directory (git-ignored). For a shared/team setup, replace this with an
  # S3 or Terraform Cloud backend.
}

############################
#        Providers         #
############################

# Low-permission default provider. In Snowflake the object creator is the default
# owner, so we use separate role-scoped provider aliases and require every resource
# to declare the role it needs.
provider "snowflake" {
  account_name      = var.account_name
  organization_name = var.organization_name
  role              = "PUBLIC"
}

provider "snowflake" {
  alias             = "sysadmin"
  role              = "SYSADMIN"
  account_name      = var.account_name
  organization_name = var.organization_name
}

provider "snowflake" {
  alias             = "securityadmin"
  role              = "SECURITYADMIN"
  account_name      = var.account_name
  organization_name = var.organization_name
}

provider "snowflake" {
  alias             = "useradmin"
  role              = "USERADMIN"
  account_name      = var.account_name
  organization_name = var.organization_name
}

############################
#        Training          #
############################

module "training" {
  source = "./modules/training"
  providers = {
    snowflake.securityadmin = snowflake.securityadmin,
    snowflake.sysadmin      = snowflake.sysadmin,
    snowflake.useradmin     = snowflake.useradmin,
  }

  name_suffix                    = var.name_suffix
  dbt_service_account_public_key = var.dbt_service_account_public_key
}
