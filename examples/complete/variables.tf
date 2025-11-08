variable "github_organization" {
  description = "GitHub organization name"
  type        = string
}

variable "repository_name_format" {
  description = "Format string for repository names (used in outputs)"
  type        = string
  default     = "platform-%s"
}
