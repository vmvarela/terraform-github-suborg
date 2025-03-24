module "repo" {
  for_each                               = local.repositories
  source                                 = "vmvarela/repository/github"
  version                                = ">= 0.3.0"
  name                                   = each.key
  alias                                  = try(each.value.alias, each.key)
  actions_access_level                   = each.value.actions_access_level
  actions_allowed_github                 = each.value.actions_allowed_github
  actions_allowed_patterns               = each.value.actions_allowed_patterns
  actions_allowed_policy                 = each.value.actions_allowed_policy
  actions_allowed_verified               = each.value.actions_allowed_verified
  allow_merge_commit                     = each.value.allow_merge_commit
  allow_rebase_merge                     = each.value.allow_rebase_merge
  allow_squash_merge                     = each.value.allow_squash_merge
  allow_update_branch                    = each.value.allow_update_branch
  archived                               = each.value.archived
  archive_on_destroy                     = each.value.archive_on_destroy
  autolink_references                    = each.value.autolink_references
  auto_init                              = each.value.auto_init
  branches                               = each.value.branches
  custom_properties                      = each.value.custom_properties
  custom_properties_types                = each.value.custom_properties_types
  default_branch                         = each.value.default_branch
  delete_branch_on_merge                 = each.value.delete_branch_on_merge
  dependabot_secrets                     = each.value.dependabot_secrets
  dependabot_secrets_encrypted           = each.value.dependabot_secrets_encrypted
  deploy_keys                            = each.value.deploy_keys
  description                            = each.value.description
  enable_actions                         = each.value.enable_actions
  enable_advanced_security               = each.value.enable_advanced_security
  enable_secret_scanning                 = each.value.enable_secret_scanning
  enable_secret_scanning_push_protection = each.value.enable_secret_scanning_push_protection
  enable_vulnerability_alerts            = each.value.enable_vulnerability_alerts
  environments                           = each.value.environments
  files                                  = each.value.files
  gitignore_template                     = each.value.gitignore_template
  has_downloads                          = each.value.has_downloads
  has_issues                             = each.value.has_issues
  has_projects                           = each.value.has_projects
  has_wiki                               = each.value.has_wiki
  homepage                               = each.value.homepage
  is_template                            = each.value.is_template
  issue_labels                           = each.value.issue_labels
  issue_labels_colors                    = each.value.issue_labels_colors
  license_template                       = each.value.license_template
  merge_commit_message                   = each.value.merge_commit_message
  merge_commit_title                     = each.value.merge_commit_title
  pages_build_type                       = each.value.pages_build_type
  pages_cname                            = each.value.pages_cname
  pages_source_branch                    = each.value.pages_source_branch
  pages_source_path                      = each.value.pages_source_path
  private                                = each.value.private
  rulesets                               = each.value.rulesets
  secrets                                = each.value.secrets
  secrets_encrypted                      = each.value.secrets_encrypted
  squash_merge_commit_message            = each.value.squash_merge_commit_message
  squash_merge_commit_title              = each.value.squash_merge_commit_title
  teams                                  = each.value.teams
  template                               = each.value.template
  template_include_all_branches          = each.value.template_include_all_branches
  topics                                 = each.value.topics
  users                                  = each.value.users
  variables                              = each.value.variables
  visibility                             = each.value.visibility
  web_commit_signoff_required            = each.value.web_commit_signoff_required
  webhooks                               = each.value.webhooks
}
