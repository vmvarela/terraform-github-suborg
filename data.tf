# data "github_repositories" "this" {
#   query           = "org:${var.organization}"
#   include_repo_id = true
# }
#
# data "github_organization" "this" {
#   name = var.organization
# }
#
# data "github_organization_teams" "this" {
#   summary_only = true
# }
