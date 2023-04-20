#########################################################
# Output resource data
#########################################################

output "application" {
  value       = azuread_application.app_spn
  description = "The app registration resource"
}

output "service_principal" {
  value       = azuread_service_principal.app_spn
  description = "The service principal resource"
}

output "application_password" {
  value       = azuread_application_password.app_spn
  description = "The password for the application"
}
