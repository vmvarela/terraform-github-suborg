locals {
  merge_keys = [
    "autolink_references",
    "branches",
    "dependabot_secrets",
    "deploy_keys",
    "environments",
    "files",
    "issue_labels",
    "properties",
    "rulesets",
    "secrets",
    "teams",
    "users",
    "variables",
    "webhooks"
  ]
  union_keys = [
    "topics"
  ]
  coalesce_keys = [
    "actions_access_level",
    "actions_permissions",
    "advanced_security",
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
    "gitignore_template",
    "has_discussions",
    "has_issues",
    "has_projects",
    "has_wiki",
    "homepage_url",
    "ignore_vulnerability_alerts_during_read",
    "is_template",
    "license_template",
    "merge_commit_message",
    "merge_commit_title",
    "pages",
    "private",
    "secret_scanning",
    "secret_scanning_push_protection",
    "squash_merge_commit_message",
    "squash_merge_commit_title",
    "template",
    "template_include_all_branches",
    "visibility",
    "vulnerability_alerts",
    "web_commit_signoff_required"
  ]
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
}
