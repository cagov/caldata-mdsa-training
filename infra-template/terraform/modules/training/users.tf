######################################
#         dbt Service Account         #
######################################

# A single service user for dbt, authenticated with an RSA key pair (never a
# password). The learner generates a key pair, sets the public key here via the
# `dbt_service_account_public_key` variable, and stores the private key as a
# GitHub Actions secret. The public key must be supplied without the PEM header,
# trailer, and line breaks.
resource "snowflake_service_user" "dbt" {
  provider          = snowflake.useradmin
  name              = "DBT_SVC_USER_${var.name_suffix}"
  comment           = "Service user for dbt (transforms the training database)"
  default_warehouse = module.transforming.name
  default_role      = snowflake_account_role.transformer.name
  rsa_public_key    = var.dbt_service_account_public_key
}

# Grant the transformer functional role to the dbt service user.
resource "snowflake_grant_account_role" "transformer_to_dbt" {
  provider  = snowflake.useradmin
  role_name = snowflake_account_role.transformer.name
  user_name = snowflake_service_user.dbt.name
}
