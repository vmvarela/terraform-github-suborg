locals {
  settings     = yamldecode(file("${path.module}/config/settings.yaml"))
  defaults     = yamldecode(file("${path.module}/config/defaults.yaml"))
  repositories = yamldecode(file("${path.module}/config/repositories.yaml"))
}
