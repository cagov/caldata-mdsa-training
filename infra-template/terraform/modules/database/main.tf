######################################
#            Terraform               #
######################################

terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 1.0"
      configuration_aliases = [
        snowflake.securityadmin,
        snowflake.sysadmin,
        snowflake.useradmin,
      ]
    }
  }
  required_version = ">= 1.0"
}

######################################
#           Permissions              #
######################################

# NOTE: We use the long access-control-type names (READWRITECONTROL rather than
# RWC) to avoid a Snowflake provider bug where object names with underscores are
# treated as wildcards and collide in state.
# https://github.com/Snowflake-Labs/terraform-provider-snowflake/issues/1527

locals {
  # Access control permissions for database objects.
  database = {
    READ             = ["USAGE"]
    READWRITE        = ["USAGE"]
    READWRITECONTROL = ["USAGE", "CREATE SCHEMA"]
  }

  # Access control permissions for schema objects.
  schema = {
    READ      = ["USAGE"]
    READWRITE = ["USAGE"]
    READWRITECONTROL = [
      "CREATE FILE FORMAT",
      "CREATE FUNCTION",
      "CREATE PIPE",
      "CREATE PROCEDURE",
      "CREATE STAGE",
      "CREATE TABLE",
      "CREATE TEMPORARY TABLE",
      "CREATE VIEW",
      "MODIFY",
      "MONITOR",
      "USAGE",
    ]
  }

  # Access control permissions for table objects.
  table = {
    READ = ["SELECT", "REFERENCES"]
    READWRITE = [
      "DELETE",
      "INSERT",
      "TRUNCATE",
      "UPDATE",
    ]
    READWRITECONTROL = [
      "DELETE",
      "INSERT",
      "TRUNCATE",
      "UPDATE",
    ]
  }

  # Access control permissions for view objects.
  view = {
    READ             = ["SELECT", "REFERENCES"]
    READWRITE        = ["SELECT", "REFERENCES"]
    READWRITECONTROL = ["SELECT", "REFERENCES"]
  }
}

#######################################
#              Database               #
#######################################

resource "snowflake_database" "this" {
  provider                    = snowflake.sysadmin
  name                        = var.name
  comment                     = var.comment
  data_retention_time_in_days = var.data_retention_time_in_days
}

######################################
#            Access Roles            #
######################################

resource "snowflake_account_role" "this" {
  provider = snowflake.useradmin
  for_each = toset(keys(local.database))
  name     = "${snowflake_database.this.name}_${each.key}"
  comment  = "${each.key} access to ${snowflake_database.this.name}"
}

resource "snowflake_grant_account_role" "this_to_sysadmin" {
  provider         = snowflake.useradmin
  for_each         = toset(keys(local.database))
  role_name        = snowflake_account_role.this[each.key].name
  parent_role_name = "SYSADMIN"
}

######################################
#   Database/Schema/Table Grants     #
######################################

# Database grants
resource "snowflake_grant_privileges_to_account_role" "database" {
  provider          = snowflake.securityadmin
  for_each          = local.database
  privileges        = each.value
  account_role_name = snowflake_account_role.this[each.key].name
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.this.name
  }
  with_grant_option = false
}

# Schema grants (future + PUBLIC). READWRITECONTROL owns future schemas so it can
# create/drop objects created by dbt.
resource "snowflake_grant_ownership" "schemas" {
  provider          = snowflake.securityadmin
  account_role_name = snowflake_account_role.this["READWRITECONTROL"].name
  on {
    future {
      object_type_plural = "SCHEMAS"
      in_database        = snowflake_database.this.name
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "schemas" {
  provider          = snowflake.securityadmin
  for_each          = local.schema
  privileges        = each.value
  account_role_name = snowflake_account_role.this[each.key].name
  on_schema {
    future_schemas_in_database = snowflake_database.this.name
  }
  with_grant_option = false
}

resource "snowflake_grant_privileges_to_account_role" "public" {
  provider          = snowflake.securityadmin
  for_each          = local.schema
  privileges        = each.value
  account_role_name = snowflake_account_role.this[each.key].name
  on_schema {
    schema_name = "${snowflake_database.this.name}.PUBLIC"
  }
  with_grant_option = false
}

# Table grants
resource "snowflake_grant_ownership" "tables" {
  provider          = snowflake.securityadmin
  account_role_name = snowflake_account_role.this["READWRITECONTROL"].name
  on {
    future {
      object_type_plural = "TABLES"
      in_database        = snowflake_database.this.name
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "tables" {
  provider          = snowflake.securityadmin
  for_each          = local.table
  privileges        = each.value
  account_role_name = snowflake_account_role.this[each.key].name
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_database        = snowflake_database.this.name
    }
  }
  with_grant_option = false
}

# View grants
resource "snowflake_grant_ownership" "views" {
  provider          = snowflake.securityadmin
  account_role_name = snowflake_account_role.this["READWRITECONTROL"].name
  on {
    future {
      object_type_plural = "VIEWS"
      in_database        = snowflake_database.this.name
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "views" {
  provider          = snowflake.securityadmin
  for_each          = local.view
  privileges        = each.value
  account_role_name = snowflake_account_role.this[each.key].name
  on_schema_object {
    future {
      object_type_plural = "VIEWS"
      in_database        = snowflake_database.this.name
    }
  }
  with_grant_option = false
}
