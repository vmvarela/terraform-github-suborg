# Unit tests for terraform-github-suborg module
# Tests configuration precedence, merge strategies, and repository creation

mock_provider "github" {
  alias = "mock"

  # Mock data for repository resource
  mock_resource "github_repository" {
    defaults = {
      id             = "test-repo-id"
      full_name      = "test-org/test-repo"
      html_url       = "https://github.com/test-org/test-repo"
      ssh_clone_url  = "git@github.com:test-org/test-repo.git"
      http_clone_url = "https://github.com/test-org/test-repo.git"
      git_clone_url  = "git://github.com/test-org/test-repo.git"
      node_id        = "test-node-id"
      repo_id        = 12345
    }
  }

  # Mock data for branch protection
  mock_resource "github_branch_protection" {
    defaults = {
      id            = "test-branch-protection-id"
      pattern       = "main"
      repository_id = "test-repo-id"
    }
  }

  # Mock data for team repository
  mock_resource "github_team_repository" {
    defaults = {
      id         = "test-team-repo-id"
      team_id    = "test-team-id"
      repository = "test-repo"
      permission = "push"
    }
  }

  # Mock data for repository collaborator
  mock_resource "github_repository_collaborator" {
    defaults = {
      id         = "test-collaborator-id"
      repository = "test-repo"
      username   = "test-user"
      permission = "push"
    }
  }

  # Mock data for actions secret
  mock_resource "github_actions_secret" {
    defaults = {
      id          = "test-secret-id"
      repository  = "test-repo"
      secret_name = "TEST_SECRET"
      created_at  = "2024-01-01T00:00:00Z"
      updated_at  = "2024-01-01T00:00:00Z"
    }
  }

  # Mock data for actions variable
  mock_resource "github_actions_variable" {
    defaults = {
      id            = "test-variable-id"
      repository    = "test-repo"
      variable_name = "TEST_VARIABLE"
      created_at    = "2024-01-01T00:00:00Z"
      updated_at    = "2024-01-01T00:00:00Z"
    }
  }
}

# Test 1: Basic repository creation with spec formatting
run "repository_creation_with_spec" {
  command = plan

  variables {
    spec = "test-org-%s"
    repositories = {
      "api"      = { description = "API service" }
      "frontend" = { description = "Frontend app" }
    }
  }

  assert {
    condition     = length(keys(output.repositories)) == 2
    error_message = "Should create exactly 2 repositories"
  }

  assert {
    condition     = contains(keys(output.repositories), "api")
    error_message = "Should contain 'api' repository"
  }

  assert {
    condition     = contains(keys(output.repositories), "frontend")
    error_message = "Should contain 'frontend' repository"
  }
}

# Test 2: Repository naming with alias override
run "repository_naming_with_alias" {
  command = plan

  variables {
    spec = "prefix-%s"
    repositories = {
      "service-a" = {
        description = "Service A"
      }
      "service-b" = {
        alias       = "custom-name"
        description = "Service B with custom name"
      }
    }
  }

  assert {
    condition     = contains(keys(output.repositories), "custom-name")
    error_message = "Repository key should be 'custom-name' when alias is provided"
  }

  assert {
    condition     = !contains(keys(output.repositories), "service-b")
    error_message = "Original key 'service-b' should be replaced by alias 'custom-name'"
  }
}

# Test 3: Settings propagation (fixed configuration)
run "settings_propagation" {
  command = plan

  variables {
    settings = {
      visibility = "private"
      topics     = ["terraform-managed", "production"]
      has_issues = true
    }
    repositories = {
      "repo-1" = { description = "Repository 1" }
      "repo-2" = { description = "Repository 2" }
    }
  }

  assert {
    condition = alltrue([
      for name, config in output.repositories :
      config.visibility == "private"
    ])
    error_message = "All repositories should have private visibility from settings"
  }

  assert {
    condition = alltrue([
      for name, config in output.repositories :
      contains(config.topics, "terraform-managed") && contains(config.topics, "production")
    ])
    error_message = "All repositories should inherit topics from settings"
  }
}

# Test 4: Defaults usage (can be overridden)
run "defaults_usage" {
  command = plan

  variables {
    defaults = {
      visibility             = "public"
      delete_branch_on_merge = true
      has_wiki               = false
      has_projects           = false
    }
    repositories = {
      "repo-1" = {
        description = "Uses all defaults"
      }
      "repo-2" = {
        description = "Overrides visibility"
        visibility  = "private"
      }
    }
  }

  assert {
    condition     = output.repositories["repo-1"].visibility == "public"
    error_message = "repo-1 should use default visibility 'public'"
  }

  assert {
    condition     = output.repositories["repo-2"].visibility == "private"
    error_message = "repo-2 should override visibility to 'private'"
  }

  assert {
    condition = alltrue([
      for name, config in output.repositories :
      config.delete_branch_on_merge == true
    ])
    error_message = "All repositories should inherit delete_branch_on_merge from defaults"
  }
}

# Test 5: Configuration precedence (settings > repository > defaults for coalesce keys)
run "configuration_precedence" {
  command = plan

  variables {
    defaults = {
      description = "Default description"
      visibility  = "public"
      has_issues  = true
    }
    settings = {
      has_wiki = false
    }
    repositories = {
      "repo-with-defaults" = {}
      "repo-with-override" = {
        description = "Custom description"
        visibility  = "internal"
      }
    }
  }

  # Test that repository config overrides defaults when settings not specified
  assert {
    condition     = output.repositories["repo-with-override"].visibility == "internal"
    error_message = "Repository-specific visibility should override defaults"
  }

  assert {
    condition     = output.repositories["repo-with-override"].description == "Custom description"
    error_message = "Repository-specific description should override defaults"
  }

  # Test that defaults are used when nothing else is specified
  assert {
    condition     = output.repositories["repo-with-defaults"].description == "Default description"
    error_message = "Should use default description when not specified elsewhere"
  }

  assert {
    condition     = output.repositories["repo-with-defaults"].visibility == "public"
    error_message = "Should use default visibility when not specified elsewhere"
  }
}

# Test 6: Union merge strategy for topics
run "union_merge_topics" {
  command = plan

  variables {
    settings = {
      topics = ["settings-topic", "common"]
    }
    defaults = {
      topics = ["default-topic"]
    }
    repositories = {
      "repo-1" = {
        description = "Test repository"
        topics      = ["repo-specific", "api"]
      }
      "repo-2" = {
        description = "Another repository"
      }
    }
  }

  # Repo-1 should have union of settings + repo topics
  assert {
    condition = alltrue([
      contains(output.repositories["repo-1"].topics, "settings-topic"),
      contains(output.repositories["repo-1"].topics, "common"),
      contains(output.repositories["repo-1"].topics, "repo-specific"),
      contains(output.repositories["repo-1"].topics, "api")
    ])
    error_message = "repo-1 should have union of settings and repository topics"
  }

  # Repo-2 should have settings topics (no repo-specific)
  assert {
    condition = alltrue([
      contains(output.repositories["repo-2"].topics, "settings-topic"),
      contains(output.repositories["repo-2"].topics, "common")
    ])
    error_message = "repo-2 should inherit settings topics"
  }
}

# Test 7: Merge strategy for teams and users
run "merge_teams_and_users" {
  command = plan

  variables {
    teams = {
      "platform-team" = "admin"
      "dev-team"      = "push"
    }
    users = {
      "external-user" = "pull"
    }
    settings = {
      teams = {
        "security-team" = "maintain"
      }
      users = {
        "bot-user" = "pull"
      }
    }
    repositories = {
      "repo-1" = {
        description = "Repository with extra teams"
        teams = {
          "repo-specific-team" = "push"
        }
        users = {
          "repo-admin" = "admin"
        }
      }
    }
  }

  # Should merge teams from all levels
  assert {
    condition = alltrue([
      contains(keys(output.repositories["repo-1"].teams), "platform-team"),
      contains(keys(output.repositories["repo-1"].teams), "dev-team"),
      contains(keys(output.repositories["repo-1"].teams), "security-team"),
      contains(keys(output.repositories["repo-1"].teams), "repo-specific-team")
    ])
    error_message = "Should merge teams from top-level, settings, and repository config"
  }

  # Should merge users from all levels
  assert {
    condition = alltrue([
      contains(keys(output.repositories["repo-1"].users), "external-user"),
      contains(keys(output.repositories["repo-1"].users), "bot-user"),
      contains(keys(output.repositories["repo-1"].users), "repo-admin")
    ])
    error_message = "Should merge users from top-level, settings, and repository config"
  }
}

# Test 8: Merge strategy for secrets and variables
run "merge_secrets_and_variables" {
  command = plan

  variables {
    settings = {
      secrets = {
        "COMMON_SECRET" = "common-value"
        "API_KEY"       = "settings-key"
      }
      variables = {
        "ENVIRONMENT" = "production"
      }
    }
    defaults = {
      secrets = {
        "DEFAULT_SECRET" = "default-value"
      }
      variables = {
        "LOG_LEVEL" = "info"
      }
    }
    repositories = {
      "repo-1" = {
        description = "Repo with specific secrets"
        secrets = {
          "REPO_SECRET" = "repo-value"
          "API_KEY"     = "repo-override" # Should override settings
        }
        variables = {
          "CUSTOM_VAR" = "custom-value"
        }
      }
    }
  }

  # Should merge secrets from settings and repository
  assert {
    condition = alltrue([
      contains(keys(output.repositories["repo-1"].secrets), "COMMON_SECRET"),
      contains(keys(output.repositories["repo-1"].secrets), "REPO_SECRET"),
      contains(keys(output.repositories["repo-1"].secrets), "API_KEY")
    ])
    error_message = "Should merge secrets from settings and repository config"
  }

  # In merge strategy, later values override earlier ones (settings + repository)
  # So repository secrets merged with settings secrets, with repository values taking precedence
  assert {
    condition     = length(keys(output.repositories["repo-1"].secrets)) >= 3
    error_message = "Should have at least 3 secrets from merged configuration"
  }

  # Should merge variables from all levels
  assert {
    condition = alltrue([
      contains(keys(output.repositories["repo-1"].variables), "ENVIRONMENT"),
      contains(keys(output.repositories["repo-1"].variables), "CUSTOM_VAR")
    ])
    error_message = "Should merge variables from settings and repository config"
  }
}

# Test 9: Empty configuration handling
run "empty_configuration" {
  command = plan

  variables {
    repositories = {
      "minimal-repo" = {}
    }
  }

  assert {
    condition     = length(keys(output.repositories)) == 1
    error_message = "Should create repository even with empty configuration"
  }

  assert {
    condition     = contains(keys(output.repositories), "minimal-repo")
    error_message = "Should create 'minimal-repo' with empty config"
  }
}

# Test 10: Multiple repositories with mixed configurations
run "mixed_configurations" {
  command = plan

  variables {
    spec = "org-%s"
    defaults = {
      visibility             = "public"
      delete_branch_on_merge = true
      has_issues             = true
    }
    settings = {
      topics = ["managed"]
      autolink_references = {
        "JIRA-" = "https://jira.company.com/browse/<num>"
      }
    }
    teams = {
      "core-team" = "admin"
    }
    repositories = {
      "api" = {
        description = "API service"
        visibility  = "private"
        topics      = ["backend", "api"]
        variables = {
          "SERVICE_PORT" = "8080"
        }
      }
      "frontend" = {
        description                 = "Frontend application"
        has_wiki                    = true
        topics                      = ["react", "frontend"]
        enable_vulnerability_alerts = true
      }
      "library" = {
        description = "Shared library"
        is_template = true
        topics      = ["library", "typescript"]
      }
    }
  }

  assert {
    condition     = length(keys(output.repositories)) == 3
    error_message = "Should create exactly 3 repositories"
  }

  # API repo should override visibility
  assert {
    condition     = output.repositories["api"].visibility == "private"
    error_message = "API repository should override visibility to private"
  }

  # All repos should have 'managed' topic from settings
  assert {
    condition = alltrue([
      for name, config in output.repositories :
      contains(config.topics, "managed")
    ])
    error_message = "All repositories should have 'managed' topic from settings"
  }

  # API repo should have union of settings + repo topics
  assert {
    condition = alltrue([
      contains(output.repositories["api"].topics, "managed"),
      contains(output.repositories["api"].topics, "backend"),
      contains(output.repositories["api"].topics, "api")
    ])
    error_message = "API repo should have union of all topics"
  }

  # All repos should inherit autolink references from settings
  assert {
    condition = alltrue([
      for name, config in output.repositories :
      contains(keys(config.autolink_references), "JIRA-")
    ])
    error_message = "All repositories should inherit autolink references from settings"
  }

  # Library should be marked as template
  assert {
    condition     = output.repositories["library"].is_template == true
    error_message = "Library repository should be marked as template"
  }
}

# Test 11: Environments merge
run "environments_merge" {
  command = plan

  variables {
    settings = {
      environments = {
        "production" = {
          wait_timer = 30
        }
      }
    }
    repositories = {
      "app-repo" = {
        description = "Repository with environments"
        environments = {
          "staging" = {
            wait_timer = 10
          }
        }
      }
    }
  }

  # Should merge environments from settings and repository
  assert {
    condition = alltrue([
      contains(keys(output.repositories["app-repo"].environments), "production"),
      contains(keys(output.repositories["app-repo"].environments), "staging")
    ])
    error_message = "Should merge environments from settings and repository config"
  }
}

# Test 12: Spec format validation
run "spec_format_validation" {
  command = plan

  variables {
    spec = "team-%s-service"
    repositories = {
      "auth"    = { description = "Auth service" }
      "payment" = { description = "Payment service" }
    }
  }

  assert {
    condition     = length(keys(output.repositories)) == 2
    error_message = "Should create repositories with formatted names"
  }
}

# Test 13: Output validation
run "output_validation" {
  command = plan

  variables {
    spec = "test-%s"
    defaults = {
      visibility = "public"
    }
    repositories = {
      "repo-1" = { description = "Test repo 1" }
      "repo-2" = { description = "Test repo 2" }
    }
  }

  assert {
    condition     = length(keys(output.repositories)) == 2
    error_message = "Output should contain all repositories"
  }

  assert {
    condition = alltrue([
      for name, config in output.repositories :
      config.visibility == "public"
    ])
    error_message = "Output repositories should reflect merged configuration"
  }
}

# Test 14: Autolink references merge
run "autolink_references_merge" {
  command = plan

  variables {
    settings = {
      autolink_references = {
        "JIRA-"   = "https://jira.company.com/browse/<num>"
        "TICKET-" = "https://tickets.company.com/view/<num>"
      }
    }
    repositories = {
      "repo-1" = {
        description = "Repository with additional autolinks"
        autolink_references = {
          "PR-" = "https://internal.company.com/pr/<num>"
        }
      }
    }
  }

  # Should merge autolink references
  assert {
    condition = alltrue([
      contains(keys(output.repositories["repo-1"].autolink_references), "JIRA-"),
      contains(keys(output.repositories["repo-1"].autolink_references), "TICKET-"),
      contains(keys(output.repositories["repo-1"].autolink_references), "PR-")
    ])
    error_message = "Should merge autolink references from settings and repository"
  }
}

# Test 15: Issue labels merge
run "issue_labels_merge" {
  command = plan

  variables {
    settings = {
      issue_labels = {
        "bug"  = "Critical bug"
        "feat" = "New feature"
      }
    }
    repositories = {
      "repo-1" = {
        description = "Repository with custom labels"
        issue_labels = {
          "hotfix"   = "Urgent hotfix"
          "security" = "Security issue"
        }
      }
    }
  }

  # Should merge issue labels
  assert {
    condition = alltrue([
      contains(keys(output.repositories["repo-1"].issue_labels), "bug"),
      contains(keys(output.repositories["repo-1"].issue_labels), "feat"),
      contains(keys(output.repositories["repo-1"].issue_labels), "hotfix"),
      contains(keys(output.repositories["repo-1"].issue_labels), "security")
    ])
    error_message = "Should merge issue labels from settings and repository"
  }
}
