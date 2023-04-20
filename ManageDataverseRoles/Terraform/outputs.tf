output "function_app_name" {
  value       = module.function_app.function_app.name
  description = "Name of the function app."
}

output "application_insights_id" {
  value       = module.lookup.application_insights.app_id
  description = "Id of application insights resource to register deployment with."
}

output "keyvault_name" {
  value       = module.lookup.key_vault.name
  description = "Name of the key vault to retrieve the appinsights api key from."
}
