output "repositories" {
  description = "Map of all created repositories with their configurations"
  value       = module.github_suborg.repositories
}

output "repository_names" {
  description = "List of repository names"
  value       = keys(module.github_suborg.repositories)
}
