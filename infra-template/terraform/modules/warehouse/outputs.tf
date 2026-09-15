output "access_role_name" {
  description = "Warehouse access role (MONITOR/OPERATE/USAGE)"
  value       = snowflake_account_role.this.name
}

output "name" {
  description = "Warehouse name"
  value       = snowflake_warehouse.this.name
}
