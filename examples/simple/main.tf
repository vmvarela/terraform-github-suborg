module "github" {
  source = "../../"
  # organization = "vmvarela-org-testing"
  # name         = "test"
  spec         = "test-suborg-%"
  teams        = { "MYTEAM" = "push" }
  settings     = local.settings
  defaults     = local.defaults
  repositories = local.repositories
}
