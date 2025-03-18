variable "defaults" {
  description = "(Optional) Default configuration (if empty)"
  type        = any
  default     = {}
}

variable "repositories" {
  description = "(Optional) Repositories settings"
  type        = any
  default     = {}
}

variable "settings" {
  description = "(Optional) Fixed common configuration (cannot be overwritten)"
  type        = any
  default     = {}
}
