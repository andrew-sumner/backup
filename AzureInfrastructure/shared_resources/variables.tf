locals {
  env = merge(
    yamldecode(file("env/${terraform.workspace}.yaml")),
    { "environment_name" = terraform.workspace }
  )
}
