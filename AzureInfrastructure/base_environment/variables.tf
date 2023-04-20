locals {
  env = merge(
    yamldecode(file("env/${terraform.workspace}.yaml")),
    { "environment_name" = terraform.workspace }
  )
}

locals {
  # Minimun size for a development plan for Azure Functions WITHOUT ip restrictions enabled
  # Is not suitable for production
  default_plan_sku = {
    tier      = "Basic"
    size      = "B1"
    capacity  = null
    autoscale = false
    autoscale_start_capacity = 0
  }
  # default_plan_sku = {
  #   tier = "Standard"
  #   size = "S1"
  #   capacity = null
  # }
  # Minimun size for a development plan for Azure Functions WITH ip restrictions enabled
  # default_sku = {
  #   tier = "PremiumV2"
  #   size = "P1v2"
  #   capacity = null
  # }

  app_service_plan_sku = lookup(local.env, "app_service_plan_sku", local.default_plan_sku)

  # Minium size for basic environment, if have networking enabled will need Premium, 1
  default_bus_sku = {
    sku      = "Basic"
    capacity = 0
  }

  servicebus_sku = lookup(local.env, "servicebus_sku", local.default_bus_sku)
}