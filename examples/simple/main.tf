module "github" {
  source = "../../"
  # organization = "vmvarela"
  settings     = local.settings
  defaults     = local.defaults
  repositories = local.repositories
}
