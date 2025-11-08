# Terraform Tests

This directory contains native HCL unit tests for the `terraform-github-suborg` module using Terraform's built-in testing framework with mock providers.

## Overview

The test suite validates all core functionality of the module including:

- Repository creation and naming conventions
- Configuration precedence (repository > settings > defaults)
- Merge strategies (coalesce, union, merge)
- Team and user permissions
- Secrets and variables management
- Branch protection and rulesets
- Topics and autolink references
- Issue labels configuration

## Test Structure

### Mock Provider Configuration

The tests use a mock GitHub provider to simulate GitHub API responses without making actual API calls. This allows for:

- Fast test execution
- No external dependencies
- Consistent, repeatable results
- No API rate limiting concerns

### Test Cases

| Test | Description | What It Validates |
|------|-------------|-------------------|
| `repository_creation_with_spec` | Basic repository creation | Correct number of repositories and spec formatting |
| `repository_naming_with_alias` | Alias override functionality | Custom repository names override spec format |
| `settings_propagation` | Fixed settings application | Settings apply to all repositories and cannot be overridden |
| `defaults_usage` | Default values application | Defaults apply when not specified elsewhere and can be overridden |
| `configuration_precedence` | Priority order validation | Correct precedence: repository > settings > defaults |
| `union_merge_topics` | Topics union merge | Topics from multiple sources are combined (union) |
| `merge_teams_and_users` | Teams/users merge strategy | Teams and users from all levels are merged |
| `merge_secrets_and_variables` | Secrets/variables merge | Secrets and variables are properly merged with overrides |
| `empty_configuration` | Minimal config handling | Module works with empty repository configuration |
| `mixed_configurations` | Complex multi-repo setup | Multiple repositories with different configurations |
| `branch_protection_merge` | Branch protection merge | Branch configurations from multiple sources merge correctly |
| `spec_format_validation` | Name formatting | Repository names follow spec format pattern |
| `output_validation` | Module outputs | Outputs contain correct merged configurations |
| `autolink_references_merge` | Autolink merge strategy | Autolink references merge from settings and repository |
| `issue_labels_merge` | Issue labels merge | Issue labels merge from settings and repository |

## Running the Tests

### Prerequisites

- Terraform >= 1.7.0
- GitHub provider >= 6.6.0

### Execute All Tests

```bash
terraform test
```

**Expected Output:**
```
tests/suborg.tftest.hcl... in progress
  run "repository_creation_with_spec"... pass
  run "repository_naming_with_alias"... pass
  run "settings_propagation"... pass
  run "defaults_usage"... pass
  run "configuration_precedence"... pass
  run "union_merge_topics"... pass
  run "merge_teams_and_users"... pass
  run "merge_secrets_and_variables"... pass
  run "empty_configuration"... pass
  run "mixed_configurations"... pass
  run "environments_merge"... pass
  run "spec_format_validation"... pass
  run "output_validation"... pass
  run "autolink_references_merge"... pass
  run "issue_labels_merge"... pass
tests/suborg.tftest.hcl... pass

Success! 15 passed, 0 failed.
```

### Execute Specific Test File

```bash
terraform test -filter=tests/suborg.tftest.hcl
```

### Execute Specific Test Case

```bash
terraform test -run=repository_creation_with_spec
```

### Verbose Output

```bash
terraform test -verbose
```

## Merge Strategies Tested

### 1. Coalesce Keys (First Non-Null Wins)

Used for scalar values where the first non-null value is selected following precedence order:

**Order**: Repository Config → Settings → Defaults

**Example**: `visibility`, `description`, `private`, `archived`, etc.

```hcl
defaults = { visibility = "public" }
settings = { visibility = "private" }
repositories = {
  "repo-1" = { visibility = "internal" }  # Wins: "internal"
  "repo-2" = {}                            # Gets: "private" (from settings)
}
```

### 2. Union Keys (Combine Arrays)

Used for list values where elements are combined from all sources:

**Sources**: Settings + Repository Config (Defaults if both empty)

**Example**: `files`, `topics`, `webhooks`

```hcl
settings = { topics = ["terraform", "managed"] }
repositories = {
  "repo-1" = { topics = ["api", "backend"] }  # Result: ["terraform", "managed", "api", "backend"]
}
```

### 3. Merge Keys (Deep Merge Maps)

Used for map values where keys are merged from all sources:

**Sources**: Settings + Repository Config (Defaults if both empty)

**Example**: `teams`, `users`, `secrets`, `variables`, `branches`, `environments`, etc.

```hcl
settings = {
  teams = { "platform-team" = "admin" }
  secrets = { "API_KEY" = "settings-value" }
}
repositories = {
  "repo-1" = {
    teams = { "dev-team" = "push" }           # Result: both teams
    secrets = { "API_KEY" = "override" }      # Overrides settings value
  }
}
```

## Test Coverage

The test suite covers:

- ✅ Repository creation with various configurations
- ✅ Name formatting with `spec` parameter
- ✅ Alias override functionality
- ✅ Configuration precedence rules
- ✅ All three merge strategies (coalesce, union, merge)
- ✅ Team and user permissions
- ✅ Secrets and variables (plain and encrypted)
- ✅ Branch protection and rulesets
- ✅ Topics management
- ✅ Autolink references
- ✅ Issue labels and colors
- ✅ Empty and minimal configurations
- ✅ Complex multi-repository scenarios
- ✅ Output validation

## Continuous Integration

These tests can be integrated into CI/CD pipelines:

### GitHub Actions Example

```yaml
name: Terraform Tests

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: "1.7.0"

      - name: Run Tests
        run: terraform test
```

## Best Practices

1. **Mock Providers**: All tests use mock providers to avoid external dependencies
2. **Descriptive Names**: Test names clearly describe what is being validated
3. **Comprehensive Assertions**: Each test includes multiple assertions for thorough validation
4. **Edge Cases**: Tests cover empty configs, overrides, and complex scenarios
5. **Fast Execution**: Mock providers ensure tests run quickly without API calls

## Adding New Tests

When adding new functionality to the module, follow these steps:

1. Add a new `run` block in `suborg.tftest.hcl`
2. Use descriptive test names: `run "test_name"`
3. Include relevant `variables` for the test scenario
4. Add multiple `assert` blocks to validate different aspects
5. Provide clear `error_message` descriptions

Example:

```hcl
run "my_new_feature" {
  command = plan

  variables {
    # Test-specific variables
  }

  assert {
    condition     = # Test condition
    error_message = "Clear description of what failed"
  }
}
```

## Troubleshooting

### Test Failures

If a test fails:

1. Check the error message for specific assertion that failed
2. Run with `-verbose` flag for detailed output
3. Verify the test scenario matches the expected behavior
4. Review recent changes to the module

### Common Issues

- **Mock provider not configured**: Ensure `mock_provider` block is present
- **Assertion condition errors**: Check that the condition references valid paths
- **Variable type mismatches**: Verify variable types match module expectations

## Resources

- [Terraform Testing Documentation](https://developer.hashicorp.com/terraform/language/tests)
- [Mock Providers Guide](https://developer.hashicorp.com/terraform/language/tests/mocking)
- [HCL Testing Best Practices](https://developer.hashicorp.com/terraform/tutorials/configuration-language/test)
