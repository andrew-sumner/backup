terraform {
  required_version = ">=0.14.0"

  required_providers {
    azurerm = ">=3.45.0"
  }
}

data "azurerm_resource_group" "main" {
  name = local.resource_names.resource_group
}

data "azurerm_key_vault" "main" {
  count = local.resource_names.key_vault == null ? 0 : 1

  name                = local.resource_names.key_vault
  resource_group_name = local.resource_names.resource_group
}

data "azurerm_storage_account" "main" {
  count = local.resource_names.storage_account == null ? 0 : 1

  name                = local.resource_names.storage_account
  resource_group_name = local.resource_names.resource_group
}

data "azurerm_service_plan" "main" {
  count = local.resource_names.app_service_plan == null ? 0 : 1

  name                = local.resource_names.app_service_plan
  resource_group_name = local.resource_names.resource_group
}

data "azurerm_application_insights" "main" {
  count = local.resource_names.application_insights == null ? 0 : 1

  name                = local.resource_names.application_insights
  resource_group_name = local.resource_names.resource_group
}

data "azurerm_servicebus_namespace" "main" {
  count = local.resource_names.servicebus_namespace == null ? 0 : 1

  name                = local.resource_names.servicebus_namespace
  resource_group_name = local.resource_names.resource_group
}

# Some teams choose not to add virtual network to all environments, this attempts to see if it has one before looking it up
locals {
  check_vnet  = local.resource_names.virtual_network != null
  lookup_vnet = local.check_vnet && (var.vnet_is_optional == false || (var.vnet_is_optional && try(length(flatten(data.azurerm_key_vault.main[0].network_acls.*.virtual_network_subnet_ids)), 0) > 0))
}

data "azurerm_virtual_network" "main" {
  count = local.lookup_vnet ? 1 : 0

  name                = local.resource_names.virtual_network
  resource_group_name = local.resource_names.resource_group
}

locals {
  allsubnets = lookup(element(concat(data.azurerm_virtual_network.main, [{}]), 0), "subnets", [])

  # Get list of subnets starting matching filter, if not provided return nothing
  subnets         = [for s in local.allsubnets : s if length(regexall(coalesce(var.subnet_filter, "!!"), s)) > 0]
  private_subnets = [for s in local.allsubnets : s if length(regexall(coalesce(var.private_subnet_filter, "!!"), s)) > 0]
}

data "azurerm_subnet" "main" {
  count                = length(local.subnets)
  name                 = local.subnets[count.index]
  virtual_network_name = local.resource_names.virtual_network
  resource_group_name  = local.resource_names.resource_group
}

data "azurerm_subnet" "private" {
  count                = length(local.private_subnets)
  name                 = local.private_subnets[count.index]
  virtual_network_name = local.resource_names.virtual_network
  resource_group_name  = local.resource_names.resource_group
}
