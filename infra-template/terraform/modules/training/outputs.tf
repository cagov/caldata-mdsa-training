output "database_name" {
  description = "Name of the training database"
  value       = module.training.name
}

output "warehouse_names" {
  description = "Names of the three training warehouses"
  value = [
    module.loading.name,
    module.transforming.name,
    module.reporting.name,
  ]
}

output "role_names" {
  description = "Names of the three functional roles"
  value = [
    snowflake_account_role.loader.name,
    snowflake_account_role.transformer.name,
    snowflake_account_role.reporter.name,
  ]
}

output "dbt_service_user_name" {
  description = "Name of the dbt service user"
  value       = snowflake_service_user.dbt.name
}
