# Simple Example - Basic GitHub Sub-Organization Setup
#
# This example demonstrates a simple configuration for managing
# multiple repositories with shared settings and defaults.

terraform {
  required_version = ">= 1.7"

  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 6.6.0"
    }
  }
}

provider "github" {
  owner = var.github_organization
  # token is read from GITHUB_TOKEN environment variable
}

module "github_suborg" {
  source = "../../"

  # Optional: Format repository names with a prefix
  spec = "myteam-%s"

  # Common settings applied to all repositories (cannot be overridden)
  settings = {
    visibility = "private"
    topics     = ["terraform-managed", "myteam"]
  }

  # Default values (can be overridden by individual repositories)
  defaults = {
    delete_branch_on_merge = true
    has_issues             = true
    has_wiki               = false
    has_projects           = false
  }

  # Define your repositories
  repositories = {
    api = {
      description = "API service"
      topics      = ["api", "backend"]
    }

    frontend = {
      description = "Frontend application"
      topics      = ["frontend", "react"]
      has_wiki    = true # Override default
    }

    shared-library = {
      description = "Shared utilities library"
      is_template = true
      topics      = ["library"]
    }
  }

  # Common collaborators for all repositories
  teams = {
    "engineering-team" = "push"
    "admin-team"       = "admin"
  }

  users = {
    "external-contractor" = "pull"
  }
}
