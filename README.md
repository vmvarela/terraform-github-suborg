# GitHub Sub-Org Terraform module

This module simplifies the management of multiple repositories by applying common settings, permissions, and configurations in a unified way.

## Usage

```hcl
module "suborg" {
  source = "github.com/vmvarela/terraform-github-suborg"
  repositories = {
    my-repo-1 = {
      visibility     = "private"
      default_branch = "main"
      template       = "MarketingPipeline/Awesome-Repo-Template"
    }
    my-repo-2 = {
      visibility     = "public"
      default_branch = "master"
      template       = "vmvarela/template"
    }
  }
}
```

## Examples

- [simple](https://github.com/vmvarela/terraform-github-suborg/tree/master/examples/simple) - Single repositories group


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7 |
| <a name="requirement_github"></a> [github](#requirement\_github) | >= 6.6.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_repo"></a> [repo](#module\_repo) | vmvarela/repository/github | 0.3.3 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_defaults"></a> [defaults](#input\_defaults) | Default configuration for repositories (overwritten by repository settings) | `any` | `{}` | no |
| <a name="input_repositories"></a> [repositories](#input\_repositories) | Map of repositories (key: name, value: settings). See terraform-github-repository module for details. | `any` | `{}` | no |
| <a name="input_settings"></a> [settings](#input\_settings) | Fixed common configuration (cannot be overwritten) | `any` | `{}` | no |
| <a name="input_spec"></a> [spec](#input\_spec) | Format specification for repository names (i.e "prefix-%s") | `string` | `null` | no |
| <a name="input_teams"></a> [teams](#input\_teams) | The list of collaborators (teams) of all repositories | `map(string)` | `{}` | no |
| <a name="input_users"></a> [users](#input\_users) | The list of collaborators (users) of al repositories | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_repositories"></a> [repositories](#output\_repositories) | List of created repositories |
<!-- END_TF_DOCS -->

## Authors

Module is maintained by [Victor M. Varela](https://github.com/vmvarela).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/vmvarela/terraform-github-subgroup/tree/master/LICENSE) for full details.
