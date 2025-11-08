# Complete Example - Advanced GitHub Sub-Organization Setup
#
# This example demonstrates all features available in the
# terraform-github-suborg module including:
# - Multiple repositories with different configurations
# - Branch protection and rulesets
# - Secrets and variables management
# - Webhooks and deploy keys
# - Issue labels and autolink references
# - GitHub Actions configuration
# - Security features
# - Environment-specific settings

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

module "github_platform" {
  source = "../../"

  # Format repository names with organization prefix
  spec = "platform-%s"

  # Fixed settings that apply to all repositories
  settings = {
    # Common visibility
    visibility = "private"

    # Organization-wide topics
    topics = ["platform", "terraform-managed", "production"]

    # Common autolink references for issue tracking
    autolink_references = {
      "JIRA-"   = "https://jira.company.com/browse/<num>"
      "TICKET-" = "https://tickets.company.com/view/<num>"
    }

    # Security settings for all repositories
    enable_vulnerability_alerts        = true
    enable_dependabot_security_updates = true

    # Common webhooks
    webhooks = ["https://webhooks.company.com/github"]

    # Common teams with base permissions
    teams = {
      "platform-team" = "admin"
      "security-team" = "maintain"
    }
  }

  # Default values for repositories
  defaults = {
    # Merge settings
    delete_branch_on_merge      = true
    allow_squash_merge          = true
    allow_merge_commit          = false
    allow_rebase_merge          = false
    squash_merge_commit_title   = "PR_TITLE"
    squash_merge_commit_message = "PR_BODY"

    # Features
    has_issues   = true
    has_wiki     = false
    has_projects = false

    # GitHub Actions
    enable_actions = true

    # Default issue labels
    issue_labels = {
      "bug"           = "Something isn't working"
      "enhancement"   = "New feature or request"
      "documentation" = "Improvements or additions to documentation"
    }

    # Default issue label colors
    issue_labels_colors = {
      "bug"           = "d73a4a"
      "enhancement"   = "a2eeef"
      "documentation" = "0075ca"
    }
  }

  # Repository definitions
  repositories = {
    # API Gateway Service
    api-gateway = {
      description = "API Gateway - Main entry point for all services"
      homepage    = "https://api.company.com"

      topics = ["api", "gateway", "backend", "nodejs"]

      # GitHub Actions secrets
      secrets = {
        "AWS_ACCESS_KEY_ID"     = "AKIA..."
        "AWS_SECRET_ACCESS_KEY" = "secret123"
        "DATADOG_API_KEY"       = "datadog-key"
      }

      # GitHub Actions variables
      variables = {
        "AWS_REGION"   = "us-east-1"
        "SERVICE_PORT" = "8080"
        "LOG_LEVEL"    = "info"
        "ENVIRONMENT"  = "production"
      }

      # Environment-specific configurations
      environments = {
        "production" = {
          wait_timer = 30
          reviewers = {
            teams = ["platform-team"]
          }
        }
        "staging" = {
          wait_timer = 0
        }
      }

      # Repository-specific webhooks
      webhooks = ["https://api-gateway.webhooks.company.com/deploy"]

      # Additional teams
      teams = {
        "api-team" = "push"
      }

      # Custom issue labels
      issue_labels = {
        "critical"    = "Critical bug that needs immediate attention"
        "performance" = "Performance improvement"
      }

      issue_labels_colors = {
        "critical"    = "ff0000"
        "performance" = "00ff00"
      }
    }

    # Frontend Application
    frontend-app = {
      description = "Frontend application - React SPA"
      homepage    = "https://app.company.com"

      topics = ["frontend", "react", "typescript", "spa"]

      # Enable wiki for frontend documentation
      has_wiki = true

      # GitHub Pages configuration
      pages_source_branch = "main"
      pages_source_path   = "/docs"
      pages_build_type    = "legacy"

      secrets = {
        "VERCEL_TOKEN"      = "vercel-token"
        "SENTRY_AUTH_TOKEN" = "sentry-token"
      }

      variables = {
        "REACT_APP_API_URL"     = "https://api.company.com"
        "REACT_APP_ENVIRONMENT" = "production"
      }

      environments = {
        "production" = {
          wait_timer = 30
          reviewers = {
            teams = ["frontend-team"]
          }
        }
        "preview" = {
          wait_timer = 0
        }
      }

      teams = {
        "frontend-team" = "push"
        "design-team"   = "pull"
      }

      issue_labels = {
        "ui"   = "User interface related"
        "ux"   = "User experience related"
        "a11y" = "Accessibility"
      }

      issue_labels_colors = {
        "ui"   = "1d76db"
        "ux"   = "5319e7"
        "a11y" = "b60205"
      }
    }

    # Shared Library
    shared-library = {
      description = "Shared utilities and common code"

      topics = ["library", "typescript", "utilities", "shared"]

      # Mark as template repository
      is_template = true

      # Enable discussions for library users
      has_discussions = true

      # Template settings
      template_include_all_branches = false

      # Advanced security features
      enable_advanced_security               = true
      enable_secret_scanning                 = true
      enable_secret_scanning_push_protection = true

      teams = {
        "library-maintainers" = "maintain"
      }

      # Custom autolink for library-specific issues
      autolink_references = {
        "LIB-" = "https://internal.company.com/library/issues/<num>"
      }
    }

    # Infrastructure as Code Repository
    infrastructure = {
      description = "Terraform infrastructure code"

      topics = ["terraform", "infrastructure", "iac", "aws"]

      # Strict branch protection via rulesets
      rulesets = {
        "main-protection" = {
          enforcement = "active"
          target      = "branch"
          bypass_actors = [
            {
              actor_id    = 1 # Organization admins
              actor_type  = "OrganizationAdmin"
              bypass_mode = "always"
            }
          ]
          conditions = {
            ref_name = {
              include = ["refs/heads/main"]
              exclude = []
            }
          }
          rules = {
            creation                = true
            update                  = true
            deletion                = true
            required_linear_history = true
            required_signatures     = true

            pull_request = {
              required_approving_review_count = 2
              dismiss_stale_reviews_on_push   = true
              require_code_owner_review       = true
              require_last_push_approval      = true
            }

            required_status_checks = {
              strict_required_status_checks_policy = true
              required_status_checks = [
                {
                  context = "terraform-plan"
                },
                {
                  context = "terraform-validate"
                },
                {
                  context = "security-scan"
                }
              ]
            }
          }
        }
      }

      secrets = {
        "AWS_ACCESS_KEY_ID"     = "AKIA..."
        "AWS_SECRET_ACCESS_KEY" = "secret123"
        "TERRAFORM_CLOUD_TOKEN" = "tf-token"
      }

      variables = {
        "TF_VERSION"    = "1.7.0"
        "AWS_REGION"    = "us-east-1"
        "WORKSPACE_ENV" = "production"
      }

      teams = {
        "infrastructure-team" = "admin"
        "developers"          = "pull"
      }

      issue_labels = {
        "terraform" = "Terraform related"
        "aws"       = "AWS infrastructure"
        "urgent"    = "Urgent infrastructure change"
      }

      issue_labels_colors = {
        "terraform" = "623ce4"
        "aws"       = "ff9900"
        "urgent"    = "ff0000"
      }
    }

    # Microservice Template
    service-template = {
      description = "Template for creating new microservices"

      topics = ["template", "microservice", "nodejs", "docker"]

      is_template = true

      # Initialize with README
      auto_init          = true
      gitignore_template = "Node"
      license_template   = "mit"

      template_include_all_branches = true

      # Files to include in the template
      files = [
        {
          file      = "README.md"
          from_file = "${path.module}/templates/service-README.md"
        },
        {
          file      = "Dockerfile"
          from_file = "${path.module}/templates/Dockerfile"
        },
        {
          file      = ".github/workflows/ci.yml"
          from_file = "${path.module}/templates/ci-workflow.yml"
        }
      ]

      teams = {
        "template-maintainers" = "admin"
      }
    }

    # Documentation Repository
    docs = {
      description = "Platform documentation and guides"
      homepage    = "https://docs.company.com"

      topics = ["documentation", "guides", "wiki"]

      has_wiki   = true
      visibility = "public" # Override settings - make docs public

      # GitHub Pages for documentation
      pages_source_branch = "main"
      pages_source_path   = "/"
      pages_cname         = "docs.company.com"
      pages_build_type    = "workflow"

      teams = {
        "documentation-team" = "maintain"
      }

      users = {
        "tech-writer-1" = "push"
        "tech-writer-2" = "push"
      }

      issue_labels = {
        "content"     = "Content updates"
        "typo"        = "Typo or grammar fix"
        "translation" = "Translation needed"
      }

      issue_labels_colors = {
        "content"     = "0e8a16"
        "typo"        = "d4c5f9"
        "translation" = "fbca04"
      }
    }
  }

  # Global team permissions
  teams = {
    "engineering" = "push"
    "qa-team"     = "pull"
  }

  # Individual user access
  users = {
    "external-auditor" = "pull"
  }
}
