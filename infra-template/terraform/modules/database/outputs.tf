output "name" {
  description = "Database name"
  value       = snowflake_database.this.name
}

output "read_role_name" {
  description = "READ access role for the database"
  value       = snowflake_account_role.this["READ"].name
}

output "readwritecontrol_role_name" {
  description = "READWRITECONTROL access role for the database"
  value       = snowflake_account_role.this["READWRITECONTROL"].name
}
