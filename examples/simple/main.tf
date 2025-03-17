module "github" {
  source       = "../../"
  settings     = local.settings
  defaults     = local.defaults
  repositories = local.repositories
}
