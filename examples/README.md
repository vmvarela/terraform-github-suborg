# Examples

This directory contains examples demonstrating different use cases and configurations for the `terraform-github-suborg` module.

## Available Examples

### [Simple Example](./simple)

A basic example showing typical usage for managing a small set of repositories with common settings.

**Use this example if you:**
- Are getting started with the module
- Have a simple repository structure
- Want to see basic configuration patterns
- Need a quick setup

**Features demonstrated:**
- Repository creation with name formatting
- Common settings and defaults
- Team and user permissions
- Topic management
- Basic overrides

**Repositories created:** 3
**Configuration complexity:** Low
**Estimated setup time:** 5-10 minutes

[View simple example →](./simple)

---

### [Complete Example](./complete)

A comprehensive example showcasing all features and advanced configurations for enterprise-scale deployments.

**Use this example if you:**
- Need advanced security features
- Want to see all available options
- Are managing a large platform
- Require complex branch protection
- Need environment-specific configurations

**Features demonstrated:**
- All repository configuration options
- Branch protection rulesets
- Secrets and variables management
- GitHub Actions environments
- Webhooks and deploy keys
- Custom issue labels
- Autolink references
- GitHub Pages configuration
- Advanced security features
- Template repositories
- Multiple merge strategies

**Repositories created:** 6
**Configuration complexity:** High
**Estimated setup time:** 30-60 minutes

[View complete example →](./complete)

---

## Quick Start

### Prerequisites

For all examples:
- Terraform >= 1.7
- GitHub provider >= 6.6.0
- GitHub organization with admin access
- GitHub personal access token

### Running an Example

1. **Choose an example** and navigate to its directory:
   ```bash
   cd simple  # or cd complete
   ```

2. **Set up authentication:**
   ```bash
   export GITHUB_TOKEN="your-github-token"
   ```

3. **Configure variables:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your organization name
   ```

4. **Initialize and apply:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Comparison

| Feature | Simple | Complete |
|---------|--------|----------|
| Repositories | 3 | 6 |
| Branch Protection | ❌ | ✅ Rulesets |
| Secrets Management | ❌ | ✅ Multiple |
| Environments | ❌ | ✅ Multiple |
| GitHub Pages | ❌ | ✅ |
| Template Repos | ✅ 1 | ✅ 2 |
| Advanced Security | ❌ | ✅ |
| Custom Labels | ❌ | ✅ |
| Webhooks | ❌ | ✅ |
| Deploy Keys | ❌ | Documented |
| File Management | ❌ | ✅ |
| Complexity | Low | High |
| Lines of Code | ~60 | ~400+ |

## Learning Path

**Recommended learning path:**

1. Start with the **[simple example](./simple)** to understand basic concepts
2. Review the outputs and created resources
3. Try modifying the simple example with your own repositories
4. Move to the **[complete example](./complete)** to explore advanced features
5. Pick specific features from the complete example for your use case

## Common Use Cases

### Scenario 1: Small Team Startup

**Best example:** Simple

You have 3-5 repositories and a small team. You want to standardize repository settings and manage permissions centrally.

### Scenario 2: Growing Organization

**Best example:** Complete (simplified)

You're scaling from a few to dozens of repositories. You need:
- Standardized security settings
- Branch protection
- Secrets management
- Team-based permissions

Use the complete example as a reference, but start with fewer repositories.

### Scenario 3: Enterprise Platform

**Best example:** Complete

You're managing a large platform with:
- Multiple teams and services
- Strict security requirements
- Complex deployment workflows
- Compliance needs

The complete example demonstrates all features you'll need.

## Customization Tips

### Adding Repositories

Both examples make it easy to add repositories. Just add entries to the `repositories` map:

```hcl
repositories = {
  # ... existing ...

  new-repo = {
    description = "New repository"
    topics      = ["tag1", "tag2"]
  }
}
```

### Adjusting Security

Start with basic security in the simple example, then gradually add:
1. Vulnerability alerts (simple)
2. Dependabot updates (simple)
3. Branch protection (complete)
4. Advanced security (complete - requires GitHub Enterprise)

### Team Management

Define teams at three levels:
- **Global**: `teams = { ... }` - applies to all repos
- **Settings**: `settings = { teams = { ... } }` - fixed for all repos
- **Repository**: Per-repo teams for specific access

### Secrets Strategy

1. **Development**: Use variables for non-sensitive data
2. **Staging**: Use secrets with moderate protection
3. **Production**: Use encrypted secrets with environment protection

## Testing Examples

Before applying to production:

1. **Use a test organization:**
   ```bash
   github_organization = "test-org"
   ```

2. **Start with plan:**
   ```bash
   terraform plan -out=plan.tfplan
   ```

3. **Review carefully:**
   - Check repository names
   - Verify team permissions
   - Review security settings

4. **Apply incrementally:**
   Create a few repositories first, validate, then add more.

## Cleaning Up

To remove all created resources:

```bash
terraform destroy
```

**Note:** Repositories are archived by default, not deleted. To permanently delete, set:

```hcl
defaults = {
  archive_on_destroy = false
}
```

## Getting Help

- Read the [main documentation](../README.md)
- Check the [test cases](../tests) for more examples
- Review [testing guide](../tests/TESTING_GUIDE.md) for patterns
- Open an issue on GitHub

## Contributing Examples

Have a useful example? We'd love to include it!

Requirements for new examples:
- Complete README with usage instructions
- Working Terraform configuration
- Clear use case description
- Proper variable handling
- Security best practices

## Additional Resources

- [Terraform GitHub Provider Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs)
- [GitHub API Documentation](https://docs.github.com/en/rest)
- [Module Registry Page](https://registry.terraform.io/modules/vmvarela/suborg/github)
