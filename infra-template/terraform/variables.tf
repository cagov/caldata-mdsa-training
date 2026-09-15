variable "account_name" {
  description = "Snowflake account name (from your account locator / URL)"
  type        = string
}

variable "organization_name" {
  description = "Snowflake organization name"
  type        = string
}

variable "name_suffix" {
  description = "Suffix applied to every object name. Use a unique per-learner value (e.g. your initials) when multiple learners share one Snowflake account. Defaults to DEV."
  type        = string
  default     = "DEV"
}

variable "dbt_service_account_public_key" {
  description = <<-EOT
    RSA public key for the dbt service user, with the PEM header/trailer and all
    line breaks removed (a single line starting with 'MII...'). Leave unset on the
    first apply, then set it and re-apply once you have generated a key pair.
  EOT
  type        = string
  default     = null
}
