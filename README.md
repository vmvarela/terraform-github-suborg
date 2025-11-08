# Terraform GitHub Sub-Organization Module

This Terraform module provides a simple and flexible way to manage multiple GitHub repositories with shared configurations, acting as a "sub-organization" within your GitHub organization. It allows you to define common settings, defaults, and repository-specific configurations, reducing duplication and simplifying repository management at scale.

## Features

- **Centralized Configuration**: Define common settings that apply to all repositories in your sub-organization
- **Default Values**: Set organization-wide defaults that can be overridden at the repository level
- **DRY Principle**: Avoid repetition by sharing configurations across repositories
- **Flexible Overrides**: Repository-specific settings take precedence over defaults
- **Naming Conventions**: Support for repository name formatting with the `spec` variable
- **Comprehensive Repository Management**: Supports all features from the underlying [terraform-github-repository](https://registry.terraform.io/modules/vmvarela/repository/github) module including:
  - Branch protection rules and rulesets
  - GitHub Actions configuration
  - Secrets and variables management
  - Deploy keys and webhooks
  - Issue labels and autolink references
  - Team and user permissions
  - GitHub Pages configuration
  - Security settings (Dependabot, secret scanning, vulnerability alerts)

## Usage

### Basic Example

```hcl
module "suborg" {
  source  = "vmvarela/suborg/github"
  version = "~> 1.0"

  # Optional: Format repository names with a prefix
  spec = "myteam-%s"

  # Common settings applied to all repositories (cannot be overridden)
  settings = {
    visibility = "private"
    topics     = ["terraform-managed"]
  }

  # Default values (can be overridden by individual repositories)
  defaults = {
    delete_branch_on_merge = true
    has_issues            = true
    has_wiki              = false
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
      has_wiki    = true  # Override default
    }
  }

  # Common collaborators for all repositories
  teams = {
    "my-team" = "push"
  }
}
```

### Advanced Example with YAML Configuration

```hcl
locals {
  defaults     = yamldecode(file("${path.module}/config/defaults.yaml"))
  settings     = yamldecode(file("${path.module}/config/settings.yaml"))
  repositories = yamldecode(file("${path.module}/config/repositories.yaml"))
}

module "suborg" {
  source  = "vmvarela/suborg/github"
  version = "~> 1.0"

  spec         = "platform-%s"
  settings     = local.settings
  defaults     = local.defaults
  repositories = local.repositories

  teams = {
    "platform-team" = "admin"
    "developers"    = "push"
  }

  users = {
    "external-contributor" = "pull"
  }
}
```

**config/defaults.yaml:**
```yaml
visibility: public
delete_branch_on_merge: true
has_issues: true
has_wiki: false
homepage: "https://mycompany.com"
topics: ["terraform-managed"]
```

**config/settings.yaml:**
```yaml
visibility: public
autolink_references:
  JIRA-: "https://jira.mycompany.com/issues/<num>"
topics: ["organization-wide"]
```

**config/repositories.yaml:**
```yaml
api-service:
  description: "Main API service"
  topics: ["api", "backend"]
  enable_actions: true
  variables:
    ENVIRONMENT: "production"

web-app:
  description: "Web application"
  homepage: "https://app.mycompany.com"
  topics: ["frontend", "react"]
  enable_vulnerability_alerts: true

shared-library:
  description: "Shared utilities library"
  is_template: true
  topics: ["library"]
```

### Repository Naming with Aliases

```hcl
module "suborg" {
  source  = "vmvarela/suborg/github"
  version = "~> 1.0"

  spec = "team-%s"

  repositories = {
    service-a = {
      description = "Service A"
    }

    service-b = {
      alias       = "team-special-name"  # Override the spec format
      description = "Service B with custom name"
    }
  }
}
```

In this example:
- `service-a` will be created as `team-service-a` (using the spec format)
- `service-b` will be created as `team-special-name` (using the alias)

## Configuration Precedence

The module applies configuration in the following order (highest to lowest priority):

1. **Repository-specific settings** - Defined directly in the repository configuration
2. **Settings** - Common settings that apply to all repositories (via `var.settings`)
3. **Defaults** - Default values that can be overridden (via `var.defaults`)

### Merge Strategies

The module uses three different merge strategies based on the configuration type:

- **Coalesce Keys** (first non-null wins): Most scalar values like `visibility`, `description`, `private`, etc.
- **Union Keys** (combine arrays): `files`, `topics`, `webhooks`
- **Merge Keys** (deep merge maps): `teams`, `users`, `secrets`, `variables`, `branches`, `environments`, etc.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.7 |
| github | >= 6.6.0 |

## Providers

| Name | Version |
|------|---------|
| github | >= 6.6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| repo | vmvarela/repository/github | 0.4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| repositories | Map of repositories (key: name, value: settings). See terraform-github-repository module for details. | `any` | `{}` | no |
| defaults | Default configuration for repositories (overwritten by repository settings) | `any` | `{}` | no |
| settings | Fixed common configuration (cannot be overwritten) | `any` | `{}` | no |
| spec | Format specification for repository names (e.g., "prefix-%s") | `string` | `null` | no |
| teams | The list of collaborators (teams) for all repositories | `map(string)` | `{}` | no |
| users | The list of collaborators (users) for all repositories | `map(string)` | `{}` | no |

### Repository Configuration Options

Each repository in the `repositories` map supports all options from the [terraform-github-repository](https://registry.terraform.io/modules/vmvarela/repository/github) module, including:

- **Basic Settings**: `description`, `homepage`, `visibility`, `private`, `archived`, `topics`
- **Features**: `has_issues`, `has_projects`, `has_wiki`, `has_downloads`, `is_template`
- **Merge Settings**: `allow_merge_commit`, `allow_squash_merge`, `allow_rebase_merge`, `allow_auto_merge`, `delete_branch_on_merge`
- **Branches**: Branch protection rules and rulesets
- **Actions**: GitHub Actions configuration and permissions
- **Security**: Advanced security, secret scanning, vulnerability alerts, Dependabot
- **Secrets & Variables**: Repository and environment-specific secrets and variables
- **Collaborators**: Team and user permissions
- **Webhooks**: Webhook configurations
- **Deploy Keys**: SSH deploy keys
- **Pages**: GitHub Pages configuration
- **Labels**: Issue labels with custom colors
- **Autolink References**: Custom autolink references for issues

## Outputs

| Name | Description |
|------|-------------|
| repositories | List of created repositories with their merged configurations |

## Testing

This module includes comprehensive unit tests using Terraform's native testing framework with mock providers. The tests validate:

- Repository creation and naming conventions
- Configuration precedence rules
- All merge strategies (coalesce, union, merge)
- Team and user permissions
- Secrets, variables, and environment configurations
- Branch protection and rulesets

### Running Tests

```bash
# Run all tests
terraform test

# Run with verbose output
terraform test -verbose

# Run specific test
terraform test -run=repository_creation_with_spec
```

See the [tests](./tests) directory for detailed test documentation and examples.

## Examples

The module includes two comprehensive examples demonstrating different use cases:

### [Simple Example](./examples/simple)
Perfect for getting started. Shows basic repository management with:
- Name formatting with prefix
- Common settings and defaults
- Team and user permissions
- 3 repositories with different configurations

**[View Simple Example →](./examples/simple)**

### [Complete Example](./examples/complete)
Enterprise-ready configuration showcasing all features:
- Advanced security settings
- Branch protection rulesets
- Secrets and variables management
- GitHub Actions environments
- Webhooks and deploy keys
- Template repositories
- GitHub Pages configuration
- 6 repositories with complex configurations

**[View Complete Example →](./examples/complete)**

For more details, see the [examples directory README](./examples/README.md).

## License

This module is released under the MIT License. See [LICENSE](./LICENSE) for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Author

This module is maintained by [vmvarela](https://github.com/vmvarela).
