# Setup function app FunctionExample-<env>
# Usage: 
#     terraform apply -input=false -var-file=env\devtt.tfvars 
#
#     All envrionments other than devtt should be deployed using the TFS release pipeline.

terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-rg"
    storage_account_name = "satestterraform"
    container_name       = "tfstate"
    key                  = "function_app.ManageDataverseRoles"
  }
}

########################################
# Configure Providers
########################################

module "global_variables" {
  source           = "git::https://tfs.westpac.co.nz/WestpacCollection/ICE/_git/AzureInfrastructure//global_variables"
  azure_tenant     = local.env.azure_tenant
  environment_name = local.env.environment_name
}

provider "azurerm" {
  features {}
  subscription_id = module.global_variables.azure.subscription_id
  tenant_id       = module.global_variables.azure.tenant_id
}

provider "azuread" {
  tenant_id = module.global_variables.azure.tenant_id
}

module "lookup" {
  source         = "git::https://stash.westpac.co.nz/scm/cp/terraform-azurerm-lookup?ref=master"
  resource_names = module.global_variables.resource_names
}

########################################
# Function App
########################################

data "azurerm_user_assigned_identity" "graph_api_identity" {
  resource_group_name = module.global_variables.shared_resource_names.resource_group
  name                = module.global_variables.shared_resource_names.graph_api_identity
}

module "function_app" {
  source = "git::https://stash.westpac.co.nz/scm/cp/terraform-azurerm-function-app.git?ref=master"

  name                 = "ManageDataverseRoles-${local.env.environment_name}"
  location             = module.lookup.resource_group.location
  resource_group       = module.lookup.resource_group
  app_service_plan     = module.lookup.app_service_plan
  application_insights = module.lookup.application_insights
  key_vault            = module.lookup.key_vault
  storage_account      = module.lookup.storage_account
  subnets              = module.lookup.subnets
  function_version     = "~4"

  always_on                  = true
  user_assigned_identity_ids = [data.azurerm_user_assigned_identity.graph_api_identity.id]

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME       = "dotnet"
    Dynamics365URL                 = "@Microsoft.KeyVault(SecretUri=${module.lookup.key_vault.vault_uri}secrets/Dynamics365URL/)"
    RemoveUsersFromTeamRole        = local.env.RemoveUsersFromTeamRole
    RemoveUsersFromSystemAdminRole = local.env.RemoveUsersFromSystemAdminRole
    GraphIdentity                  = data.azurerm_user_assigned_identity.graph_api_identity.client_id
  }

  tags = merge(module.lookup.resource_group.tags, { "Squad Name" = "The IT Crowd" })
}

###########################################
# Register Function App as Application User
###########################################

module "d365_connection_string" {
  source = "git::https://stash.westpac.co.nz/scm/cp/terraform-azure-d365.git//d365_connection_string?ref=master"

  credentials_key_vault     = module.global_variables.shared_resource_names
  dynamics365_url_key_vault = module.global_variables.resource_names
}

data "azuread_service_principal" "func_spn" {
  object_id = module.function_app.function_app.identity[0].principal_id
}

module "d365_application_user" {
  source = "git::https://stash.westpac.co.nz/scm/cp/terraform-azure-d365.git//d365_application_user?ref=master"

  dynamics365_connection_string = module.d365_connection_string.value

  ApplicationId = data.azuread_service_principal.func_spn.application_id
  FullName      = data.azuread_service_principal.func_spn.display_name
  Email         = "${data.azuread_service_principal.func_spn.display_name}@${module.global_variables.azure.email_domain_name}"
  RoleNames     = ["System Administrator"]
}


# ### DEBUG
# data "azurerm_function_app_host_keys" "item" {
#   name                = module.function_app.function_app.name
#   resource_group_name = module.function_app.function_app.resource_group_name

#   depends_on = [
#     module.function_app.function_app
#   ]
# }

# output "name" {
#   value = data.azurerm_function_app_host_keys.item
#   senstive = true
# }