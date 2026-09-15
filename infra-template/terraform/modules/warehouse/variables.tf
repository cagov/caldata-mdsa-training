variable "name" {
  description = "Warehouse name"
  type        = string
}

variable "comment" {
  description = "Comment to apply to the warehouse"
  type        = string
  default     = null
}

variable "auto_suspend" {
  description = "Auto-suspend time for the warehouse, in seconds"
  type        = number
  default     = 60
}

variable "size" {
  description = "Size of the warehouse"
  type        = string
  default     = "X-SMALL"
}
