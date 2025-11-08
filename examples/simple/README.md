# Simple Example

This example demonstrates a basic configuration for managing multiple GitHub repositories with shared settings and defaults using the `terraform-github-suborg` module.

## What This Example Creates

This example creates three repositories with a common prefix:

- `myteam-api` - API service
- `myteam-frontend` - Frontend application
- `myteam-shared-library` - Shared utilities library (marked as template)

All repositories will have:
- Private visibility
- Common topics: `terraform-managed`, `myteam`
- Team permissions for engineering and admin teams
- User access for an external contractor
- Branch deletion after merge enabled
- Issues enabled, wiki and projects disabled (except frontend which has wiki enabled)

## Prerequisites

- Terraform >= 1.7
- GitHub provider >= 6.6.0
- GitHub personal access token with `repo` and `admin:org` scopes
- GitHub organization where you have admin access

## Usage

1. **Set up authentication:**

   ```bash
   export GITHUB_TOKEN="your-github-token"
   ```

2. **Copy and configure variables:**

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

   Edit `terraform.tfvars` and set your GitHub organization name:

   ```hcl
   github_organization = "your-github-org"
   ```

3. **Initialize Terraform:**

   ```bash
   terraform init
   ```

4. **Review the plan:**

   ```bash
   terraform plan
   ```

5. **Apply the configuration:**

   ```bash
   terraform apply
   ```

## Customization

### Adding More Repositories

Add more entries to the `repositories` map in `main.tf`:

```hcl
repositories = {
  # ... existing repositories ...

  new-service = {
    description = "New service description"
    topics      = ["service", "backend"]
  }
}
```

### Changing Repository Prefix

Modify the `spec` variable:

```hcl
spec = "mycompany-%s"  # Results in: mycompany-api, mycompany-frontend, etc.
```

### Adding Team Permissions

Add more teams to the `teams` map:

```hcl
teams = {
  "engineering-team" = "push"
  "admin-team"       = "admin"
  "qa-team"          = "pull"
}
```

### Overriding Defaults

Override defaults for specific repositories:

```hcl
repositories = {
  special-repo = {
    description = "Special repository"
    has_wiki    = true     # Override default
    has_projects = true    # Override default
  }
}
```

## Expected Output

After applying, you'll see output similar to:

```
repositories = {
  "api" = {
    visibility = "private"
    topics = ["terraform-managed", "myteam", "api", "backend"]
    # ... other attributes
  }
  "frontend" = {
    visibility = "private"
    topics = ["terraform-managed", "myteam", "frontend", "react"]
    has_wiki = true
    # ... other attributes
  }
  # ...
}

repository_names = [
  "api",
  "frontend",
  "shared-library",
]
```

## Clean Up

To destroy all created resources:

```bash
terraform destroy
```

**Note:** This will archive repositories if `archive_on_destroy` is set to `true` (default behavior), or delete them permanently if set to `false`.

## Next Steps

- Check out the [complete example](../complete) for advanced features
- Review the [module documentation](../../README.md) for all available options
- See the [tests](../../tests) for more configuration examples
