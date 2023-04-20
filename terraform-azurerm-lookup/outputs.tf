output "resource_group" {
  value       = data.azurerm_resource_group.main
  description = "Resource group data object"
}

output "key_vault" {
  value       = element(concat(data.azurerm_key_vault.main, [null]), 0)
  description = "Key vault data object - if resource_names.key_vault parameter is not null"
}

output "storage_account" {
  value       = element(concat(data.azurerm_storage_account.main, [null]), 0)
  description = "Storage account data object - if resource_names.storage_account parameter is not null"
}

output "app_service_plan" {
  value       = element(concat(data.azurerm_service_plan.main, [null]), 0)
  description = "App service plan data object - if resource_names.app_service_plan parameter is not null"
}

output "application_insights" {
  value       = element(concat(data.azurerm_application_insights.main, [null]), 0)
  description = "Application insights data object - if resource_names.application_insights parameter is not null"
}

output "servicebus_namespace" {
  value       = element(concat(data.azurerm_servicebus_namespace.main, [null]), 0)
  description = "Servicebus namespace data object - if resource_names.servicebus_namespace parameter is not null"
}

output "virtual_network" {
  value       = element(concat(data.azurerm_virtual_network.main, [null]), 0)
  description = "Virtual network data object - if resource_names.virtual_network parameter is not null"
}

output "subnets" {
  value       = data.azurerm_subnet.main
  description = "List of virtual network subnets matching the subnet_filter parameter, also requires resource_names.virtual_network parameter to be populated"
}

output "private_subnet" {
  value       = element(concat(data.azurerm_subnet.private, [null]), 0)
  description = "The first virtual network subnet matching the private_subnet_filter parameter, also requires resource_names.virtual_network parameter to be populated"
}
