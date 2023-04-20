terraform {
  required_version = ">= 1.0.2"

  backend "azurerm" {
    resource_group_name  = "terraform-rg"
    storage_account_name = "satestterraform"
    container_name       = "tfstate"
    key                  = "shared"
  }
}

###################################
# Configure Providers
###################################

module "global_variables" {
  source           = "../global_variables"
  azure_tenant     = local.env.azure_tenant
  environment_name = local.env.environment_name
}

provider "azurerm" {
  features {
    key_vault {
      # key vault configured not to allow purge so terraform destroy will only soft delete they secrets / vault
      # This allows terraform to recover the secrets if the envrionment is being rebuilt
      recover_soft_deleted_key_vaults = true
      purge_soft_delete_on_destroy    = false
    }
  }

  # Prevent accidentally running against wrong subscription
  subscription_id = module.global_variables.azure.subscription_id
  tenant_id       = module.global_variables.azure.tenant_id
}

provider "azuread" {
  tenant_id = module.global_variables.azure.tenant_id
}

###################################
# Resource Group
###################################

module "resource_group" {
  source      = "git::https://stash.westpac.co.nz/scm/cp/terraform-azurerm-resource-group.git?ref=master"
  name        = module.global_variables.shared_resource_names.resource_group
  location    = module.global_variables.azure.default_resource_location
  app_owner   = module.global_variables.tags["Application Owner"]
  app_id      = module.global_variables.tags["Application ID"]
  environment = local.env.environment_type
  salary_id   = module.global_variables.tags["Salary ID"]
  squad_name  = module.global_variables.tags["Squad Name"]
  squad_code  = module.global_variables.tags["Squad Code"]
}

###################################
# Key Vault
###################################

data "azuread_service_principal" "deployment_spn" {
  display_name = module.global_variables.azure.deployment_spn_name
}

data "azuread_group" "contributor" {
  display_name = module.global_variables.azure.keyvault_contributor_group_name
}

module "key_vault" {
  source                      = "git::https://stash.westpac.co.nz/scm/cp/terraform-azurerm-key-vault.git?ref=master"
  name                        = module.global_variables.shared_resource_names.key_vault
  location                    = module.resource_group.resource_group.location
  resource_group              = module.resource_group.resource_group
  enabled_for_disk_encryption = false

  # Disable networking - will need to be added when network hub and spoke model is completed
  virtual_network_subnet_ids = null
  network_acls = {
    bypass         = "AzureServices"
    default_action = "Allow"
  }
}

resource "azurerm_key_vault_access_policy" "deploymentspn" {
  key_vault_id = module.key_vault.key_vault.id
  tenant_id    = module.key_vault.key_vault.tenant_id
  object_id    = data.azuread_service_principal.deployment_spn.id

  secret_permissions      = ["backup", "delete", "get", "list", "recover", "restore", "set"]                                                                                                                       # "purge"
  certificate_permissions = ["backup", "create", "delete", "deleteissuers", "get", "getissuers", "import", "list", "listissuers", "managecontacts", "manageissuers", "recover", "restore", "setissuers", "update"] # "purge"
  key_permissions         = ["backup", "create", "delete", "get", "import", "list", "recover", "restore", "update"]                                                                                                # "decrypt", "encrypt", "unwrapKey", "wrapKey", "verify", "sign", "purge"
}

resource "azurerm_key_vault_access_policy" "contributorgroup" {
  key_vault_id = module.key_vault.key_vault.id
  tenant_id    = module.key_vault.key_vault.tenant_id
  object_id    = data.azuread_group.contributor.id

  secret_permissions      = ["backup", "delete", "get", "list", "recover", "restore", "set"]                                                                                                                       # "purge"
  certificate_permissions = ["backup", "create", "delete", "deleteissuers", "get", "getissuers", "import", "list", "listissuers", "managecontacts", "manageissuers", "recover", "restore", "setissuers", "update"] # "purge"
  key_permissions         = ["backup", "create", "delete", "get", "import", "list", "recover", "restore", "update"]                                                                                                # "decrypt", "encrypt", "unwrapKey", "wrapKey", "verify", "sign", "purge"
}

###################################
# User Assigned Identity for graph api access
###################################

# NOTE: Cannot directly assign permission for Graph API, instead will need to have a global admin run GraphPermission.ps1
resource "azurerm_user_assigned_identity" "graph_api_identity" {
  resource_group_name = module.resource_group.resource_group.name
  location            = module.resource_group.resource_group.location

  name = module.global_variables.shared_resource_names.graph_api_identity
}

###################################
# Azure Deployment Service Principal client id and secret
###################################

data "azuread_application" "deployment_spn" {
  display_name = module.global_variables.azure.deployment_spn_name
}

resource "azurerm_key_vault_secret" "deployment_spn_clientid" {
  key_vault_id = module.key_vault.key_vault.id
  name         = "deployment-spn-clientid"
  value        = data.azuread_application.deployment_spn.application_id

  depends_on = [azurerm_key_vault_access_policy.deploymentspn, azurerm_key_vault_access_policy.contributorgroup]
}

resource "azurerm_key_vault_secret" "deployment_spn_secret" {
  key_vault_id = module.key_vault.key_vault.id
  name         = "deployment-spn-secret"
  value        = "This must be set manually"

  lifecycle {
    ignore_changes = [
      # Ignore changes to value because we are not setting it
      value
    ]
  }

  depends_on = [azurerm_key_vault_access_policy.deploymentspn, azurerm_key_vault_access_policy.contributorgroup]
}


###################################
# Test Automation Key Vault
###################################

data "azuread_group" "test_automation_contributor" {
  display_name = module.global_variables.azure.test_automation_keyvault_contributor
}

data "azuread_group" "test_automation_reader" {
  display_name = module.global_variables.azure.test_automation_keyvault_reader
}

module "test_automation_key_vault" {
  source                      = "git::https://stash.westpac.co.nz/scm/cp/terraform-azurerm-key-vault.git?ref=master"
  name                        = module.global_variables.shared_resource_names.test_automation_key_vault
  location                    = module.resource_group.resource_group.location
  resource_group              = module.resource_group.resource_group
  enabled_for_disk_encryption = false

  # Disable networking - will need to be added when network hub and spoke model is completed
  virtual_network_subnet_ids = null
  network_acls = {
    bypass         = "AzureServices"
    default_action = "Allow"
  }
}

resource "azurerm_key_vault_access_policy" "test_automation_deploymentspn" {
  key_vault_id = module.test_automation_key_vault.key_vault.id
  tenant_id    = module.test_automation_key_vault.key_vault.tenant_id
  object_id    = data.azuread_service_principal.deployment_spn.id

  secret_permissions      = ["backup", "delete", "get", "list", "recover", "restore", "set"]                                                                                                                       # "purge"
  certificate_permissions = ["backup", "create", "delete", "deleteissuers", "get", "getissuers", "import", "list", "listissuers", "managecontacts", "manageissuers", "recover", "restore", "setissuers", "update"] # "purge"
  key_permissions         = ["backup", "create", "delete", "get", "import", "list", "recover", "restore", "update"]                                                                                                # "decrypt", "encrypt", "unwrapKey", "wrapKey", "verify", "sign", "purge"
}

resource "azurerm_key_vault_access_policy" "test_automation_contributor" {
  key_vault_id = module.test_automation_key_vault.key_vault.id
  tenant_id    = module.test_automation_key_vault.key_vault.tenant_id
  object_id    = data.azuread_group.test_automation_contributor.id

  secret_permissions      = ["backup", "delete", "get", "list", "recover", "restore", "set"]                                                                                                                       # "purge"
  certificate_permissions = ["backup", "create", "delete", "deleteissuers", "get", "getissuers", "import", "list", "listissuers", "managecontacts", "manageissuers", "recover", "restore", "setissuers", "update"] # "purge"
  key_permissions         = ["backup", "create", "delete", "get", "import", "list", "recover", "restore", "update"]                                                                                                # "decrypt", "encrypt", "unwrapKey", "wrapKey", "verify", "sign", "purge"
}

resource "azurerm_key_vault_access_policy" "test_automation_reader" {
  key_vault_id = module.test_automation_key_vault.key_vault.id
  tenant_id    = module.test_automation_key_vault.key_vault.tenant_id
  object_id    = data.azuread_group.test_automation_reader.id

  secret_permissions = ["get", "list", "set"]
}

###################################
# Test Automation SPN
###################################

module "test_automation_spn" {
  source       = "git::https://stash.westpac.co.nz/scm/cp/terraform-azuread-service-principal?ref=master"
  display_name = "${upper(module.global_variables.prefix)}-TestAutomation"
  owners       = concat([data.azuread_service_principal.deployment_spn.object_id], lookup(local.env, "spn_owners", []))
}

resource "azurerm_key_vault_secret" "test_automation_client_id" {
  name         = "TestAutomation-ClientId"
  value        = module.test_automation_spn.application.application_id
  key_vault_id = module.test_automation_key_vault.key_vault.id

  depends_on = [azurerm_key_vault_access_policy.test_automation_deploymentspn, azurerm_key_vault_access_policy.test_automation_contributor]
}

resource "azurerm_key_vault_secret" "test_automation_client_secret" {
  name         = "TestAutomation-ClientSecret"
  value        = module.test_automation_spn.application_password.value
  key_vault_id = module.test_automation_key_vault.key_vault.id

  depends_on = [azurerm_key_vault_access_policy.test_automation_deploymentspn, azurerm_key_vault_access_policy.test_automation_contributor]
}

resource "azurerm_key_vault_access_policy" "test_automation_spn" {
  key_vault_id = module.test_automation_key_vault.key_vault.id
  tenant_id    = module.test_automation_key_vault.key_vault.tenant_id
  object_id    = module.test_automation_spn.service_principal.id

  secret_permissions = ["get"]
}

#######################################
# Azure AD SPN for Power Automate APIs - which not available from standard connectors
#######################################

module "app_registration" {
  source        = "git::https://stash.westpac.co.nz/scm/cp/terraform-azuread-service-principal?ref=master"
  display_name  = "PowerAutomateAPI-${local.env.environment_name}"
  redirect_uris = ["https://global.consent.azure-apim.net/redirect"]
  owners        = concat([data.azuread_service_principal.deployment_spn.object_id], lookup(local.env, "spn_owners", []))

  required_resource_access = [
    {
      resource_app_id = "00000003-0000-0000-c000-000000000000"

      # User.Read
      resource_access = [
        {
          id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
          type = "Scope"
        }
      ]
    },
    {
      resource_app_id = "7df0a125-d3be-4c96-aa54-591f83ff541c",
      resource_access = [
        {
          id   = "822a9cde-503a-472d-a530-d1dc9cd0d52b",
          type = "Scope"
        },
        {
          id   = "30b2d850-00c3-4802-b7ae-ece9af9de5c6",
          type = "Scope"
        },
        {
          id   = "e45c5562-459d-4d1b-8148-83eb1b6dcf83",
          type = "Scope"
        }
      ]
    },
  ]
}

resource "azurerm_key_vault_secret" "client_secret" {
  name         = "PowerAutomateAPI-ClientSecret"
  value        = module.app_registration.application_password.value
  key_vault_id = module.key_vault.key_vault.id
}
