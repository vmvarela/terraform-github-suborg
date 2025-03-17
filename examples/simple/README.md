# Simple GitHub suborg creation from yaml

Configuration in this directory creates repositories found in `config/repositories.yaml`
using defaults from `config/defaults.yaml`.

# Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Run `terraform destroy` when you don't need these resources.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7 |
| <a name="requirement_github"></a> [github](#requirement\_github) | >= 6.2 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_github"></a> [github](#module\_github) | ../../ | n/a |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->
