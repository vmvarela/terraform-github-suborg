locals {
  # merge settings, each repository and defaults
  repositories = { for repo, data in var.repositories : try(data.alias, repo) => merge(
    { for k in local.coalesce_keys : k => try(coalesce(lookup(var.settings, k, null), lookup(data, k, null), lookup(var.defaults, k, null)), null) },
    { for k in local.union_keys : k =>
      length(setunion([], lookup(data, k, []), lookup(var.settings, k, []))) > 0 ?
      setunion([], lookup(data, k, []), lookup(var.settings, k, [])) :
      lookup(var.defaults, k, [])
    },
    { for k in local.merge_keys : k =>
      length(merge({}, lookup(data, k, {}), lookup(var.settings, k, {}))) > 0 ?
      merge({}, lookup(data, k, {}), lookup(var.settings, k, {})) :
      lookup(var.defaults, k, {})
    }
  ) }

  # keys to set if empty: (1) settings, (2) repository, (3) defaults
  coalesce_keys = [
    "actions_access_level",
    "actions_permissions",
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
    "enable_actions",
    "enable_advanced_security",
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
    "pages",
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
    "dependabot_secrets",
    "deploy_keys",
    "environments",
    "files",
    "issue_labels",
    "rulesets",
    "secrets",
    "teams",
    "users",
    "variables",
    "webhooks"
  ]

  # keys to add (settings + repository), defaults if empty
  union_keys = [
    "topics"
  ]

}
