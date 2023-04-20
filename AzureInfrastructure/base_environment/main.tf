terraform {
  required_version = ">= 1.0.2"

  backend "azurerm" {
    resource_group_name  = "terraform-rg"
    storage_account_name = "satestterraform"
    container_name       = "tfstate"
    key                  = "resources"
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

module "shared_lookup" {
  source         = "git::https://stash.westpac.co.nz/scm/cp/terraform-azurerm-lookup?ref=master"
  resource_names = module.global_variables.shared_resource_names
}

###################################
# Resource Group
###################################

module "resource_group" {
  source      = "git::https://stash.westpac.co.nz/scm/cp/terraform-azurerm-resource-group.git?ref=master"
  name        = module.global_variables.resource_names.resource_group
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
  name                        = module.global_variables.resource_names.key_vault
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

  secret_permissions      = local.env.environment_type == "Development" ? ["backup", "delete", "get", "list", "recover", "restore", "set"] : ["get", "list"]
  certificate_permissions = local.env.environment_type == "Development" ? ["backup", "create", "delete", "deleteissuers", "get", "getissuers", "import", "list", "listissuers", "managecontacts", "manageissuers", "recover", "restore", "setissuers", "update"] : ["get", "getissuers", "list", "listissuers"]
  key_permissions         = local.env.environment_type == "Development" ? ["backup", "create", "delete", "get", "import", "list", "recover", "restore", "update"] : ["get", "list"]
}

###################################
# Application Insights
###################################

module "app_insights" {
  source = "git::https://stash.westpac.co.nz/scm/cp/terraform-azure-app-insights.git?ref=master"

  name             = module.global_variables.resource_names.application_insights
  location         = module.resource_group.resource_group.location
  resource_group   = module.resource_group.resource_group
  application_type = "web"
}

#########################################################
# Storage Account
#########################################################

module "storage_account" {
  source = "git::https://stash.westpac.co.nz/scm/cp/terraform-azurerm-storage-account.git?ref=master"

  name           = module.global_variables.resource_names.storage_account
  location       = module.resource_group.resource_group.location
  resource_group = module.resource_group.resource_group

  kind                     = "StorageV2"
  access_tier              = "Hot"
  account_replication_type = "LRS"
  account_tier             = "Standard"
  days                     = 14
  encryption_source        = null # TODO Probably needs to be Microsoft.KeyVault
  # TODO Enable networking once hub and spoke model implemented
  # virtual_network_subnet_ids  = [ module.virtual_network.subnets.*.id ]
}

#########################################################
# Service Plan
#########################################################

module "app_service_plan" {
  source = "git::https://stash.westpac.co.nz/scm/cp/terraform-azurerm-app-service-plan.git?ref=master"

  name           = module.global_variables.resource_names.app_service_plan
  location       = module.resource_group.resource_group.location
  resource_group = module.resource_group.resource_group

  kind     = "App"
  tier     = local.app_service_plan_sku.tier
  size     = local.app_service_plan_sku.size
  capacity = local.app_service_plan_sku.capacity
}

resource "azurerm_monitor_autoscale_setting" "app_service_plan" {
  count = local.app_service_plan_sku.autoscale ? 1 : 0

  name                = "${module.app_service_plan.app_service_plan.name}-Autoscale"
  location            = module.resource_group.resource_group.location
  resource_group_name = module.resource_group.resource_group.name
  target_resource_id  = module.app_service_plan.app_service_plan.id

  profile {
    name = "default"

    capacity {
      default = local.app_service_plan_sku.autoscale_start_capacity
      minimum = local.app_service_plan_sku.autoscale_start_capacity
      maximum = 5
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = module.app_service_plan.app_service_plan.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 85
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT2M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = module.app_service_plan.app_service_plan.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 70
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT2M"
      }
    }
  }
}

#########################################################
# Service Bus
#########################################################

module "servicebus_namespace" {
  source = "git::https:/stash.westpac.co.nz/scm/cp/terraform-azurerm-servicebus-namespace.git?ref=master"

  name           = module.global_variables.resource_names.servicebus_namespace
  location       = module.resource_group.resource_group.location
  resource_group = module.resource_group.resource_group

  sku        = local.servicebus_sku.sku
  capacity   = local.servicebus_sku.capacity
  subnet_ids = []
  # TODO Enable networking once hub and spoke model implemented
  # subnet_ids                  = [ module.virtual_network.subnets.*.id ]
}
