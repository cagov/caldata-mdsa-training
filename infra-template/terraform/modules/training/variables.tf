variable "name_suffix" {
  description = "Suffix applied to every object name. Use a unique per-learner value (e.g. your initials) when multiple learners share one Snowflake account."
  type        = string
}

variable "dbt_service_account_public_key" {
  description = <<-EOT
    RSA public key for the dbt service user, with the PEM header/trailer and all
    line breaks removed (a single line starting with 'MII...'). Set to null on the
    first apply if you have not generated a key yet, then re-apply once you have.
  EOT
  type        = string
  default     = null
}
