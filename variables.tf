variable "repositories" {
  description = "(Optional) List of repositories"
  type        = any
  default     = null
}

variable "defaults" {
  description = "(Optional) Default configuration"
  type        = any
  default     = null
}

variable "settings" {
  description = "(Optional) Fixed common configuration"
  type        = any
  default     = null
}
