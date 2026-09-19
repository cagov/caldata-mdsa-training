######################################
#       Functional Roles             #
######################################

# LOADER: loads raw data into the training database. Has read/write/control on the
# single training database and can use the LOADING warehouse.
resource "snowflake_account_role" "loader" {
  provider = snowflake.useradmin
  name     = "LOADER_${var.name_suffix}"
  comment  = "Permissions to load data into the ${module.training.name} database"
}

# TRANSFORMER: builds dbt models. Has read/write/control on the training database
# and can use the TRANSFORMING warehouse. Most learners use this role.
resource "snowflake_account_role" "transformer" {
  provider = snowflake.useradmin
  name     = "TRANSFORMER_${var.name_suffix}"
  comment  = "Permissions to transform data in the ${module.training.name} database"
}

# REPORTER: reads analysis-ready data for BI. Has read on the training database and
# can use the REPORTING warehouse.
resource "snowflake_account_role" "reporter" {
  provider = snowflake.useradmin
  name     = "REPORTER_${var.name_suffix}"
  comment  = "Permissions to read data from the ${module.training.name} database"
}

######################################
#  Grant functional roles to SYSADMIN
######################################

resource "snowflake_grant_account_role" "loader_to_sysadmin" {
  provider         = snowflake.useradmin
  role_name        = snowflake_account_role.loader.name
  parent_role_name = "SYSADMIN"
}

resource "snowflake_grant_account_role" "transformer_to_sysadmin" {
  provider         = snowflake.useradmin
  role_name        = snowflake_account_role.transformer.name
  parent_role_name = "SYSADMIN"
}

resource "snowflake_grant_account_role" "reporter_to_sysadmin" {
  provider         = snowflake.useradmin
  role_name        = snowflake_account_role.reporter.name
  parent_role_name = "SYSADMIN"
}

######################################
#      Database access grants        #
######################################

# Loader can read/write/control the training database.
resource "snowflake_grant_account_role" "training_rwc_to_loader" {
  provider         = snowflake.useradmin
  role_name        = module.training.readwritecontrol_role_name
  parent_role_name = snowflake_account_role.loader.name
}

# Transformer can read/write/control the training database.
resource "snowflake_grant_account_role" "training_rwc_to_transformer" {
  provider         = snowflake.useradmin
  role_name        = module.training.readwritecontrol_role_name
  parent_role_name = snowflake_account_role.transformer.name
}

# Reporter can read the training database.
resource "snowflake_grant_account_role" "training_r_to_reporter" {
  provider         = snowflake.useradmin
  role_name        = module.training.read_role_name
  parent_role_name = snowflake_account_role.reporter.name
}

######################################
#      Warehouse access grants       #
######################################

resource "snowflake_grant_account_role" "loading_to_loader" {
  provider         = snowflake.useradmin
  role_name        = module.loading.access_role_name
  parent_role_name = snowflake_account_role.loader.name
}

resource "snowflake_grant_account_role" "transforming_to_transformer" {
  provider         = snowflake.useradmin
  role_name        = module.transforming.access_role_name
  parent_role_name = snowflake_account_role.transformer.name
}

resource "snowflake_grant_account_role" "reporting_to_reporter" {
  provider         = snowflake.useradmin
  role_name        = module.reporting.access_role_name
  parent_role_name = snowflake_account_role.reporter.name
}
