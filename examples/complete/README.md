# Complete Example

This comprehensive example demonstrates all features available in the `terraform-github-suborg` module, including advanced configurations for enterprise-scale GitHub repository management.

## What This Example Creates

This example creates a complete platform setup with 6 repositories:

1. **platform-api-gateway** - API Gateway service with:
   - Multiple environments (production, staging)
   - Secrets and variables
   - Custom webhooks
   - Team permissions

2. **platform-frontend-app** - Frontend application with:
   - GitHub Pages enabled
   - Custom domain configuration
   - Design team collaboration
   - UI/UX specific labels

3. **platform-shared-library** - Shared library with:
   - Template repository configuration
   - Advanced security features (secret scanning, advanced security)
   - Library maintainer team

4. **platform-infrastructure** - Infrastructure as Code with:
   - Strict branch protection rulesets
   - Required status checks
   - Required signatures
   - Infrastructure team administration

5. **platform-service-template** - Microservice template with:
   - Pre-configured files (README, Dockerfile, CI workflow)
   - Auto-initialization with .gitignore and license
   - Template maintainers team

6. **platform-docs** - Documentation repository with:
   - Public visibility (overrides settings)
   - GitHub Pages with custom domain
   - Multiple technical writers access

## Features Demonstrated

### Repository Configuration
- ✅ Name formatting with `spec`
- ✅ Visibility overrides
- ✅ Template repositories
- ✅ Auto-initialization

### Security
- ✅ Advanced security features
- ✅ Secret scanning with push protection
- ✅ Vulnerability alerts
- ✅ Dependabot security updates
- ✅ Branch protection rulesets
- ✅ Required signatures
- ✅ Required status checks

### Collaboration
- ✅ Team permissions at multiple levels
- ✅ User permissions
- ✅ Custom issue labels
- ✅ Autolink references
- ✅ Code owner requirements

### CI/CD & Deployment
- ✅ GitHub Actions secrets
- ✅ GitHub Actions variables
- ✅ Environment-specific configurations
- ✅ Environment protection rules
- ✅ Webhooks

### Documentation & Publishing
- ✅ GitHub Pages
- ✅ Custom domains
- ✅ Wiki enablement
- ✅ Discussions

### Merge Strategies
- ✅ Coalesce keys (first non-null wins)
- ✅ Union keys (combine arrays)
- ✅ Merge keys (deep merge maps)

## Prerequisites

- Terraform >= 1.7
- GitHub provider >= 6.6.0
- GitHub personal access token with appropriate scopes:
  - `repo` (full control)
  - `admin:org` (full control)
  - `workflow` (if managing Actions secrets)
- GitHub Enterprise or GitHub Team plan (for some advanced features)
- GitHub organization with admin access

## Usage

### 1. Set Up Authentication

```bash
export GITHUB_TOKEN="your-github-token"
```

### 2. Configure Variables

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
github_organization = "your-github-org"
```

### 3. Review Template Files

The example includes template files for the service-template repository. Review and customize:

- `templates/service-README.md`
- `templates/Dockerfile`
- `templates/ci-workflow.yml`

### 4. Initialize Terraform

```bash
terraform init
```

### 5. Plan and Review

```bash
terraform plan
```

Review the execution plan carefully. This will create:
- 6 repositories
- Multiple branch protection rules
- Numerous secrets and variables
- Team and user permissions
- Webhooks

### 6. Apply Configuration

```bash
terraform apply
```

Type `yes` when prompted to confirm.

## Customization Examples

### Adding a New Service

Add to the `repositories` map in `main.tf`:

```hcl
repositories = {
  # ... existing repositories ...

  new-service = {
    description = "New microservice"
    topics      = ["microservice", "nodejs"]

    secrets = {
      "API_KEY" = "secret-value"
    }

    variables = {
      "SERVICE_PORT" = "3000"
    }

    teams = {
      "service-team" = "push"
    }
  }
}
```

### Modifying Branch Protection

Update the `rulesets` configuration:

```hcl
rulesets = {
  "main-protection" = {
    enforcement = "active"
    rules = {
      pull_request = {
        required_approving_review_count = 3  # Increase required approvals
        require_code_owner_review       = true
      }
    }
  }
}
```

### Adding Organization-Wide Secrets

Add to the `settings` block:

```hcl
settings = {
  # ... existing settings ...

  secrets = {
    "ORG_WIDE_SECRET" = "value"
  }
}
```

### Configuring Environment Protection

```hcl
environments = {
  "production" = {
    wait_timer = 60  # 60 second delay before deployment
    reviewers = {
      teams = ["platform-team", "security-team"]
      users = ["user1", "user2"]
    }
    deployment_branch_policy = {
      protected_branches     = true
      custom_branch_policies = false
    }
  }
}
```

## Expected Outputs

### Repository Names
```
repository_names = [
  "api-gateway",
  "docs",
  "frontend-app",
  "infrastructure",
  "service-template",
  "shared-library",
]
```

### Template Repositories
```
template_repositories = [
  "service-template",
  "shared-library",
]
```

### Public Repositories
```
public_repositories = [
  "docs",
]
```

### Repositories with Pages
```
repositories_with_pages = [
  "docs",
  "frontend-app",
]
```

## Advanced Configurations

### Using Encrypted Secrets

For better security, use encrypted secrets with GPG:

```hcl
secrets_encrypted = {
  "SUPER_SECRET" = "encrypted-base64-value"
}
```

Generate encrypted value:
```bash
echo -n "secret-value" | base64 | gpg --encrypt --armor -r key-id
```

### Branch Protection vs Rulesets

This example demonstrates the newer **rulesets** API which is more flexible than traditional branch protection. Rulesets support:
- Targeting multiple branches with patterns
- Bypass actors (who can bypass rules)
- More granular rule configuration
- Better organization-level management

### Deploy Keys

Add SSH deploy keys for CI/CD:

```hcl
deploy_keys = {
  "ci-deploy" = true  # Auto-generated key
}

# Or with specific key
deploy_keys_path = "${path.module}/keys"
deploy_keys = {
  "custom-key" = false  # Read-only
}
```

### Custom Properties

Use custom properties for organization-wide metadata:

```hcl
custom_properties = {
  "team"         = "platform"
  "cost-center"  = "engineering"
  "compliance"   = "sox"
}
```

## Troubleshooting

### Permission Errors

If you encounter permission errors:
1. Verify your GitHub token has all required scopes
2. Confirm you're an admin of the organization
3. Check if organization settings allow repository creation

### Advanced Security Features Not Available

Some features require GitHub Enterprise:
- Advanced Security
- Secret scanning push protection
- Code scanning

Remove these settings if you don't have Enterprise:
```hcl
# Remove these for non-Enterprise orgs
enable_advanced_security               = false
enable_secret_scanning                 = false
enable_secret_scanning_push_protection = false
```

### Ruleset Application Errors

Rulesets require specific permissions. Ensure:
- You have admin access
- The organization allows ruleset creation
- Bypass actors are valid

## Clean Up

To remove all created resources:

```bash
terraform destroy
```

**Warning:** By default, repositories are archived on destroy. To permanently delete:

```hcl
defaults = {
  archive_on_destroy = false
}
```

## Cost Considerations

This example creates resources that may have costs:
- GitHub Actions minutes (if workflows run)
- GitHub Advanced Security (Enterprise feature)
- GitHub Pages bandwidth
- Storage for large repositories

Monitor your GitHub billing to track costs.

## Security Best Practices

1. **Secrets Management**
   - Never commit secrets to version control
   - Use GitHub Actions secrets for CI/CD
   - Rotate secrets regularly
   - Use encrypted secrets when possible

2. **Access Control**
   - Follow principle of least privilege
   - Use teams for permission management
   - Require code reviews for main branches
   - Enable branch protection

3. **Security Scanning**
   - Enable Dependabot
   - Use secret scanning
   - Enable vulnerability alerts
   - Configure code scanning workflows

## Next Steps

- Review the [simple example](../simple) for a basic setup
- Check the [module documentation](../../README.md) for all options
- Explore [tests](../../tests) for more configuration patterns
- Join the community discussions

## Support

For issues or questions:
- Open an issue on GitHub
- Check the documentation
- Review test examples
