########################################
# Secret - ServiceBusConnectionString
########################################

# TODO Can we remove this and use managed identities?
resource "azurerm_key_vault_secret" "servicebsus_cs" {
  name         = "ServiceBusConnectionString"
  value        = module.servicebus_namespace.servicebus_namespace.default_primary_connection_string
  key_vault_id = module.key_vault.key_vault.id

  depends_on = [azurerm_key_vault_access_policy.deploymentspn, azurerm_key_vault_access_policy.contributorgroup]
}

########################################
# Secret - Dynamics365URL (for function and logic apps to know which envrionment to connect to)
########################################

resource "azurerm_key_vault_secret" "dynamics365_url" {
  name         = "Dynamics365URL"
  value        = local.env.dynamics365_url
  key_vault_id = module.key_vault.key_vault.id

  depends_on = [azurerm_key_vault_access_policy.deploymentspn, azurerm_key_vault_access_policy.contributorgroup]
}

########################################
# Secret - Application Insights API Permission
########################################

resource "azurerm_application_insights_api_key" "write_annotations" {
  name                    = "release-annotations"
  application_insights_id = module.app_insights.app_insights.id
  write_permissions       = ["annotations"]
}

resource "azurerm_key_vault_secret" "write_annotations" {
  name         = "appinsights-releaseannotation-apikey"
  value        = azurerm_application_insights_api_key.write_annotations.api_key
  key_vault_id = module.key_vault.key_vault.id

  depends_on = [azurerm_key_vault_access_policy.deploymentspn, azurerm_key_vault_access_policy.contributorgroup]
}

########################################
# SBUS - Give SPN permission for Datapower to send messages to ServiceBus
########################################

data "azuread_service_principal" "sbus_sender" {
  count = length(local.env.sbus_sender_spn_name) > 0 ? 1 : 0

  display_name = coalesce(local.env.sbus_sender_spn_name, "skip")
}

resource "azurerm_role_assignment" "sbus_sender" {
  count = length(local.env.sbus_sender_spn_name) > 0 ? 1 : 0

  scope                = module.servicebus_namespace.servicebus_namespace.id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = data.azuread_service_principal.sbus_sender[0].object_id
}

########################################
# Secret - DataPowerConnectionString
########################################

data "azurerm_key_vault_secret" "datapower_connection_string" {
  count = length(local.env.datapower_id) > 0 ? 1 : 0

  name         = "datapower-${local.env.datapower_id}-connectionstring"
  key_vault_id = module.shared_lookup.key_vault.id
}

resource "azurerm_key_vault_secret" "DataPowerConnectionString" {
  count = length(local.env.datapower_id) > 0 ? 1 : 0

  name         = "DataPowerConnectionString"
  value        = data.azurerm_key_vault_secret.datapower_connection_string[0].value
  key_vault_id = module.key_vault.key_vault.id

  depends_on = [azurerm_key_vault_access_policy.deploymentspn, azurerm_key_vault_access_policy.contributorgroup]
}

########################################
# Secret - FicoDataPowerConnectionString
########################################

data "azurerm_key_vault_secret" "fico_datapower_connection_string" {
  count = length(local.env.fico_datapower_id) > 0 ? 1 : 0

  name         = "datapower-${local.env.fico_datapower_id}-connectionstring"
  key_vault_id = module.shared_lookup.key_vault.id
}

resource "azurerm_key_vault_secret" "FicoDataPowerConnectionString" {
  count = length(local.env.fico_datapower_id) > 0 ? 1 : 0

  name         = "FicoDataPowerConnectionString"
  value        = data.azurerm_key_vault_secret.fico_datapower_connection_string[0].value
  key_vault_id = module.key_vault.key_vault.id

  depends_on = [azurerm_key_vault_access_policy.deploymentspn, azurerm_key_vault_access_policy.contributorgroup]
}

resource "azurerm_key_vault_secret" "FicoDataPowerSecret" {
  count = length(local.env.fico_datapower_id) > 0 ? 1 : 0

  name         = "FicoDataPowerSecret"
  value        = split("|", data.azurerm_key_vault_secret.fico_datapower_connection_string[0].value)[2]
  key_vault_id = module.key_vault.key_vault.id

  depends_on = [azurerm_key_vault_access_policy.deploymentspn, azurerm_key_vault_access_policy.contributorgroup]
}

########################################
# Secret - DocusignDataPowerConnectionString
########################################

data "azurerm_key_vault_secret" "docusign_datapower_connection_string" {
  count = length(local.env.docusign_datapower_id) > 0 ? 1 : 0

  name         = "datapower-${local.env.docusign_datapower_id}-connectionstring"
  key_vault_id = module.shared_lookup.key_vault.id
}

resource "azurerm_key_vault_secret" "DocusignDataPowerConnectionString" {
  count = length(local.env.docusign_datapower_id) > 0 ? 1 : 0

  name         = "DocusignDataPowerConnectionString"
  value        = data.azurerm_key_vault_secret.docusign_datapower_connection_string[0].value
  key_vault_id = module.key_vault.key_vault.id

  depends_on = [azurerm_key_vault_access_policy.deploymentspn, azurerm_key_vault_access_policy.contributorgroup]
}

########################################
# Secret - SecurityOperationsConnectionString
########################################

data "azurerm_key_vault_secret" "securityops_datapower_connection_string" {
  count = length(local.env.securityops_datapower_id) > 0 ? 1 : 0

  name         = "datapower-${local.env.securityops_datapower_id}-connectionstring"
  key_vault_id = module.shared_lookup.key_vault.id
}

resource "azurerm_key_vault_secret" "SecurityOperationsDataPowerConnectionString" {
  count = length(local.env.securityops_datapower_id) > 0 ? 1 : 0

  name         = "SecurityOperationsConnectionString"
  value        = data.azurerm_key_vault_secret.securityops_datapower_connection_string[0].value
  key_vault_id = module.key_vault.key_vault.id

  depends_on = [azurerm_key_vault_access_policy.deploymentspn, azurerm_key_vault_access_policy.contributorgroup]
}

########################################
# Secret - SharepointTokenUrl
########################################

data "azurerm_key_vault_secret" "SharepointTokenUrl" {
  name         = "SharepointTokenUrl"
  key_vault_id = module.shared_lookup.key_vault.id
}

resource "azurerm_key_vault_secret" "sharepointtoken_url" {
  name         = "SharepointTokenUrl"
  value        = data.azurerm_key_vault_secret.SharepointTokenUrl.value
  key_vault_id = module.key_vault.key_vault.id

  depends_on = [azurerm_key_vault_access_policy.deploymentspn, azurerm_key_vault_access_policy.contributorgroup]
}

########################################
# Secret - LincFileEncryptionPrivateKey
########################################

data "azurerm_key_vault_secret" "linc_file_encryption_private_key" {
  name         = "LincFileEncryptionPrivateKey"
  key_vault_id = module.shared_lookup.key_vault.id
}

resource "azurerm_key_vault_secret" "LincFileEncryptionPrivateKey" {
  name         = "LincFileEncryptionPrivateKey"
  value        = data.azurerm_key_vault_secret.linc_file_encryption_private_key.value
  key_vault_id = module.key_vault.key_vault.id

  depends_on = [azurerm_key_vault_access_policy.deploymentspn, azurerm_key_vault_access_policy.contributorgroup]
}

########################################
# Secret - LincFileEncryptionPassPhrase
########################################

data "azurerm_key_vault_secret" "linc_file_encryption_pass_phrase" {
  name         = "LincFileEncryptionPassPhrase"
  key_vault_id = module.shared_lookup.key_vault.id
}

resource "azurerm_key_vault_secret" "LincFileEncryptionPassPhrase" {
  name         = "LincFileEncryptionPassPhrase"
  value        = data.azurerm_key_vault_secret.linc_file_encryption_pass_phrase.value
  key_vault_id = module.key_vault.key_vault.id

  depends_on = [azurerm_key_vault_access_policy.deploymentspn, azurerm_key_vault_access_policy.contributorgroup]
}

#######################################
# Azure AD App Registration (for logic apps as they can't use managed identities yet)
#######################################

module "app_registration" {
  source       = "git::https://stash.westpac.co.nz/scm/cp/terraform-azuread-service-principal?ref=master"
  display_name = "${upper(module.global_variables.prefix)}-LogicApp-${local.env.environment_name}"
  owners       = concat([data.azuread_service_principal.deployment_spn.object_id], lookup(local.env, "spn_owners", []))
}

resource "azurerm_key_vault_secret" "client_secret" {
  name         = "LogicApp-ClientSecret"
  value        = module.app_registration.application_password.value
  key_vault_id = module.key_vault.key_vault.id

  depends_on = [azurerm_key_vault_access_policy.deploymentspn, azurerm_key_vault_access_policy.contributorgroup]
}

module "d365_connection_string" {
  source = "git::https://stash.westpac.co.nz/scm/cp/terraform-azure-d365.git//d365_connection_string?ref=master"

  credentials_key_vault     = module.global_variables.shared_resource_names
  dynamics365_url_key_vault = module.global_variables.resource_names
}

module "d365_application_user" {
  source = "git::https://stash.westpac.co.nz/scm/cp/terraform-azure-d365.git//d365_application_user?ref=master"

  dynamics365_connection_string = module.d365_connection_string.value

  ApplicationId = module.app_registration.service_principal.application_id
  FullName      = module.app_registration.service_principal.display_name
  Email         = "${module.app_registration.service_principal.display_name}@${module.global_variables.azure.email_domain_name}"
  RoleNames     = ["System Administrator"]
}
