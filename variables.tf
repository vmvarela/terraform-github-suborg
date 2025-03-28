variable "defaults" {
  description = "Default configuration for repositories (overwritten by repository settings)"
  type        = any
  default     = {}
}

# variable "name" {
#   description = "The name of the sub-org. Used for role teams creation: `<sub-org-name>-<role-name>`"
#   type        = string
# }

variable "repositories" {
  description = "Map of repositories (key: name, value: settings). See terraform-github-repository module for details."
  type        = any
  default     = {}
}

variable "settings" {
  description = "Fixed common configuration (cannot be overwritten)"
  type        = any
  default     = {}
}

variable "spec" {
  description = "Format specification for repository names (i.e \"prefix-%s\")"
  type        = string
  default     = null
}

# variable "organization" {
#   description = "Org name."
#   type        = string
# }

variable "teams" {
  description = "The list of collaborators (teams) of all repositories"
  type        = map(string)
  default     = {}
}

variable "users" {
  description = "The list of collaborators (users) of al repositories"
  type        = map(string)
  default     = {}
}
