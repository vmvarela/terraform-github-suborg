locals {
  #  # team id from a team name
  #  team_id = { for t in data.github_organization_teams.this.teams : t.name => t.id }
  #
  #  # reposity id from its repository name
  #  repository_id = { for r in data.github_repositories.this.names :
  #    r => element(data.github_repositories.this.repo_ids, index(data.github_repositories.this.names, r))
  #  }

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
