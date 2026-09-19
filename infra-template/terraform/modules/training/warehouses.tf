#################################
#           Warehouses          #
#################################

# The simplified training architecture uses three X-Small warehouses, one per
# function. X-Small is the cheapest size and is more than adequate for training
# data volumes. Warehouses auto-suspend quickly to minimize credit usage.

# Warehouse for loading raw data (used by the loader role).
module "loading" {
  source = "../warehouse"
  providers = {
    snowflake.securityadmin = snowflake.securityadmin,
    snowflake.sysadmin      = snowflake.sysadmin,
    snowflake.useradmin     = snowflake.useradmin,
  }
  name         = "LOADING_XS_${var.name_suffix}"
  comment      = "Warehouse for loading raw data into the training database"
  size         = "X-SMALL"
  auto_suspend = 60
}

# Warehouse for dbt transformations (used by the transformer role).
module "transforming" {
  source = "../warehouse"
  providers = {
    snowflake.securityadmin = snowflake.securityadmin,
    snowflake.sysadmin      = snowflake.sysadmin,
    snowflake.useradmin     = snowflake.useradmin,
  }
  name         = "TRANSFORMING_XS_${var.name_suffix}"
  comment      = "Warehouse for transforming data with dbt in the training database"
  size         = "X-SMALL"
  auto_suspend = 60
}

# Warehouse for reporting / BI (used by the reporter role).
module "reporting" {
  source = "../warehouse"
  providers = {
    snowflake.securityadmin = snowflake.securityadmin,
    snowflake.sysadmin      = snowflake.sysadmin,
    snowflake.useradmin     = snowflake.useradmin,
  }
  name         = "REPORTING_XS_${var.name_suffix}"
  comment      = "Warehouse for reporting and BI tools reading the training database"
  size         = "X-SMALL"
  auto_suspend = 60
}
