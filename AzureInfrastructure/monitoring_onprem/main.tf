#############################################################################
# WARNING: THIS IS A WORK IN PROGRESS AND HAS NOT BEEN RUN IN PRODUCTION!!! #
#############################################################################


# setup resource group and log analytics for onprem vm logs

terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-rg"
    storage_account_name = "satestterraform"  
    container_name       = "tfstate"
    key                  = "onpremmonitoring"
  }
}

module "global_variables" {
  source           = "../global_variables"
  azure_tenant     = local.env.azure_tenant
  environment_name = local.env.environment_name
}

provider "azurerm" {
  # version             = uses required version from resource_group_resources module
  features {}
  subscription_id       = module.global_variables.azure.subscription_id
  tenant_id             = module.global_variables.azure.tenant_id
}

provider "azuread" {
  # version             = uses required version from resource_group_resources module
  tenant_id             = module.global_variables.azure.tenant_id
}

###################################
# Resource Group
###################################

resource "azurerm_resource_group" "monitoring-onprem-rg" {
  name     = "monitoring-onprem-rg"
  location = module.global_variables.azure.default_resource_location
  
  tags = {
    ApplicationName = "ICEDashboard" 
    "Application Owner" = "Glen Bremner"
    Environment = "onprem"
    Squad = "IT Crowd"
  }
}

resource "azurerm_log_analytics_workspace" "pref-onprem-ws" {
  name                = "pref-onprem-ws"
  location            = azurerm_resource_group.monitoring-onprem-rg.location
  resource_group_name = azurerm_resource_group.monitoring-onprem-rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  
  tags = {
    ApplicationName = "ICEDashboard" 
    "Application Owner" = "Glen Bremner"
    Environment = "onprem"
    Squad = "IT Crowd"
  }
}