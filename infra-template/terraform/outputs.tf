output "database_name" {
  description = "Name of the training database"
  value       = module.training.database_name
}

output "warehouse_names" {
  description = "Names of the three training warehouses"
  value       = module.training.warehouse_names
}

output "role_names" {
  description = "Names of the three functional roles"
  value       = module.training.role_names
}

output "dbt_service_user_name" {
  description = "Name of the dbt service user"
  value       = module.training.dbt_service_user_name
}
