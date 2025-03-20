module "github" {
  source = "../../"
  # organization = "vmvarela-org-testing"
  settings     = local.settings
  defaults     = local.defaults
  repositories = local.repositories
}
