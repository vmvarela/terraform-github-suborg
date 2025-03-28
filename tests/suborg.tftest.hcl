provider "github" {}

variables {
    # organization = "vmvarela-org-testing"
    # name         = "tftest"
    spec         = "tftest-suborg-%s"
    users = {
      "vmvarela" = "admin"
    }
    teams = {
      "MYTEAM" = "push"
    }
    settings = {
        visibility = "private"
        topics     = ["fixed-topic"]
    }
    defaults = {
        description = "default description"
        template    = "vmvarela/template"
    }
    repositories = {
        "repo-1" = { description = "repo-1"  }
        "repo-2" = { topics = [ "repo-2-topic" ] }
    }
}

run "repositories-created" {
    command = apply
    assert {
        condition     = alltrue([for name, settings in var.repositories : module.repo[name].repository.name == format(var.spec, name)])
        error_message = "Repository name doesn't match input"
    }
}

run "settings-propagated" {
    command = apply
    assert {
        condition = alltrue([for name, settings in var.repositories :
            alltrue([ for topic in var.settings.topics :
                contains(module.repo[name].repository.topics, topic)
            ])
        ])
        error_message = "Fixed topic is not in all repositories"
    }
}

run "defaults-used-if-empty" {
    command = apply
    assert {
        condition = alltrue([for name, settings in var.repositories : module.repo[name].repository.description == var.defaults.description if try(settings.description, null) == null ])
        error_message = "Default template is not used by repositories"
    }
}
