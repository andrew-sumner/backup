data "azuread_client_config" "current" {}

module "service_principal" {
  source = "/modules"

  display_name = "ExampleSPN"
  owners       = [data.azuread_client_config.current.object_id]
}

output "azuread_application" {
  value       = module.service_principal.application
  description = "The app registration resource"
}

output "azuread_service_principal" {
  value       = module.service_principal.service_principal
  description = "The service principal resource"
}

output "secret" {
  value       = module.service_principal.application_password
  sensitive   = true
  description = "The password for the service principal"
}