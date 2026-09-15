#######################################
#            Databases                #
#######################################

# The simplified training architecture uses a SINGLE database. Learners load raw
# data, build transformations, and expose reporting models all within this one
# database, separated by schema rather than by database. This keeps the mental
# model small while still exercising role-based access control.
module "training" {
  source = "../database"
  providers = {
    snowflake.securityadmin = snowflake.securityadmin,
    snowflake.sysadmin      = snowflake.sysadmin,
    snowflake.useradmin     = snowflake.useradmin,
  }
  name                        = "TRAINING_${var.name_suffix}"
  comment                     = "Training database for the self-service training environment"
  data_retention_time_in_days = 1
}
