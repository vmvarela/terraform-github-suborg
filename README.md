# GitHub Sub-Org Terraform module

This module simplifies the management of multiple repositories by applying common settings, permissions, and configurations in a unified way.

## Usage

```hcl
module "suborg" {
  source = "github.com/vmvarela/terraform-github-suborg"
  repositories = {
    my-repo = {
      visibility     = "private"
      default_branch = "main"
      template       = "MarketingPipeline/Awesome-Repo-Template"
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
| <a name="module_repo"></a> [repo](#module\_repo) | vmvarela/repository/github | >= 0.2.4 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_defaults"></a> [defaults](#input\_defaults) | (Optional) Default configuration (if empty) | `any` | `{}` | no |
| <a name="input_repositories"></a> [repositories](#input\_repositories) | (Optional) Repositories settings | `any` | `{}` | no |
| <a name="input_settings"></a> [settings](#input\_settings) | (Optional) Fixed common configuration (cannot be overwritten) | `any` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_repositories"></a> [repositories](#output\_repositories) | List of created repositories |
<!-- END_TF_DOCS -->

## Authors

Module is maintained by [Victor M. Varela](https://github.com/vmvarela).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/vmvarela/terraform-github-subgroup/tree/master/LICENSE) for full details.
