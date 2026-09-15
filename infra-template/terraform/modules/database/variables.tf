variable "name" {
  description = "Database name"
  type        = string
}

variable "comment" {
  description = "Comment to apply to the database"
  type        = string
  default     = null
}

variable "data_retention_time_in_days" {
  description = "Time Travel data retention time in days"
  type        = number
  default     = 1
}
