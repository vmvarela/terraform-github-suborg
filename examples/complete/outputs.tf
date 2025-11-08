output "all_repositories" {
  description = "Complete configuration of all repositories"
  value       = module.github_platform.repositories
  sensitive   = true # Marked sensitive due to secrets
}

output "repository_names" {
  description = "List of all repository names"
  value       = keys(module.github_platform.repositories)
}

output "repository_full_names" {
  description = "Map of repository keys to their full formatted names"
  value = {
    for key, config in module.github_platform.repositories :
    key => format(var.repository_name_format, key)
  }
}

output "public_repositories" {
  description = "List of public repositories"
  value = [
    for key, config in module.github_platform.repositories :
    key if config.visibility == "public"
  ]
}

output "template_repositories" {
  description = "List of template repositories"
  value = [
    for key, config in module.github_platform.repositories :
    key if try(config.is_template, false)
  ]
}

output "repositories_with_pages" {
  description = "List of repositories with GitHub Pages enabled"
  value = [
    for key, config in module.github_platform.repositories :
    key if try(config.pages_source_branch, null) != null
  ]
}

output "repository_topics" {
  description = "Map of repositories to their topics"
  value = {
    for key, config in module.github_platform.repositories :
    key => config.topics
  }
}
