terraform {
  required_version = ">= 1.7"
  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 6.6.0"
    }
  }
}

locals {
  # you can set var.users and var.teams or var.settings.users and var.settings.teams
  settings = merge(var.settings, {
    "users" = merge(var.users, try(var.settings.users, {}))
    "teams" = merge(var.teams, try(var.settings.teams, {}))
  })

  # merge settings, each repository and defaults
  repositories = { for repo, data in var.repositories : try(data.alias, repo) => merge(
    { for k in local.coalesce_keys : k => try(coalesce(lookup(local.settings, k, null), lookup(data, k, null), lookup(var.defaults, k, null)), null) },
    { for k in local.union_keys : k =>
      length(setunion([], lookup(data, k, []), lookup(local.settings, k, []))) > 0 ?
      setunion(lookup(data, k, []), lookup(local.settings, k, [])) :
      lookup(var.defaults, k, [])
    },
    { for k in local.merge_keys : k =>
      length(merge(lookup(data, k, {}), lookup(local.settings, k, {}))) > 0 ?
      merge(lookup(data, k, {}), lookup(local.settings, k, {})) :
      lookup(var.defaults, k, {})
    }
  ) }

  # keys to set if empty: (1) settings, (2) repository, (3) defaults
  coalesce_keys = [
    "actions_access_level",
    "actions_allowed_github",
    "actions_allowed_patterns",
    "actions_allowed_policy",
    "actions_allowed_verified",
    "allow_auto_merge",
    "allow_merge_commit",
    "allow_rebase_merge",
    "allow_squash_merge",
    "allow_update_branch",
    "archive_on_destroy",
    "archived",
    "auto_init",
    "default_branch",
    "delete_branch_on_merge",
    "description",
    "dependabot_copy_secrets",
    "deploy_keys_path",
    "enable_actions",
    "enable_advanced_security",
    "enable_dependabot_security_updates",
    "enable_secret_scanning",
    "enable_secret_scanning_push_protection",
    "enable_vulnerability_alerts",
    "gitignore_template",
    "has_downloads",
    "has_issues",
    "has_projects",
    "has_wiki",
    "homepage",
    "is_template",
    "license_template",
    "merge_commit_message",
    "merge_commit_title",
    "pages_build_type",
    "pages_cname",
    "pages_source_branch",
    "pages_source_path",
    "private",
    "squash_merge_commit_message",
    "squash_merge_commit_title",
    "template",
    "template_include_all_branches",
    "visibility",
    "web_commit_signoff_required"
  ]

  # keys to merge (settings + repository), defaults if empty
  merge_keys = [
    "autolink_references",
    "branches",
    "custom_properties",
    "custom_properties_types",
    "dependabot_secrets",
    "dependabot_secrets_encrypted",
    "deploy_keys",
    "environments",
    "issue_labels",
    "issue_labels_colors",
    "rulesets",
    "secrets",
    "secrets_encrypted",
    "teams",
    "users",
    "variables",
  ]

  # keys to add (settings + repository), defaults if empty
  union_keys = [
    "files",
    "topics",
    "webhooks"
  ]
}

module "repo" {
  for_each                               = local.repositories
  source                                 = "vmvarela/repository/github"
  version                                = "0.4.0"
  actions_access_level                   = each.value.actions_access_level
  actions_allowed_github                 = each.value.actions_allowed_github
  actions_allowed_patterns               = each.value.actions_allowed_patterns
  actions_allowed_policy                 = each.value.actions_allowed_policy
  actions_allowed_verified               = each.value.actions_allowed_verified
  alias                                  = try(each.value.alias, each.key)
  allow_auto_merge                       = each.value.allow_auto_merge
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
  dependabot_copy_secrets                = each.value.dependabot_copy_secrets
  dependabot_secrets                     = each.value.dependabot_secrets
  dependabot_secrets_encrypted           = each.value.dependabot_secrets_encrypted
  deploy_keys                            = each.value.deploy_keys
  deploy_keys_path                       = each.value.deploy_keys_path
  description                            = each.value.description
  enable_actions                         = each.value.enable_actions
  enable_advanced_security               = each.value.enable_advanced_security
  enable_secret_scanning                 = each.value.enable_secret_scanning
  enable_secret_scanning_push_protection = each.value.enable_secret_scanning_push_protection
  enable_vulnerability_alerts            = each.value.enable_vulnerability_alerts
  enable_dependabot_security_updates     = each.value.enable_dependabot_security_updates
  environments                           = each.value.environments
  files                                  = each.value.files
  gitignore_template                     = each.value.gitignore_template
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
  name                                   = try(format(var.spec, each.key), each.key)
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
