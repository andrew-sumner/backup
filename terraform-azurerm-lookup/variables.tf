variable "resource_names" {
  type        = map(any)
  description = "The names of the resources to look up, if a name is null the resource will not be looked up."
}

variable "vnet_is_optional" {
  type        = bool
  description = "If virtual network is optional, check that it exists before looking it up. This checks that the key vault is attached to a subnet before looking up the virtual network."
  default     = false
}

variable "subnet_filter" {
  type        = string
  description = "RegEx to filter subnets with, e.g. \"(?i)delegated.*\" will perform a case insensitive search and return all subnets starting with 'Delegated'. By default will return all subnets."
  default     = null
}

variable "private_subnet_filter" {
  type        = string
  description = "RegEx to filter subnets with, e.g. \"(?i)private.*\" will perform a case insensitive search and return all subnets starting with 'General'. By default will return all subnets."
  default     = null
}

locals {
  resource_names = {
    resource_group       = var.resource_names.resource_group
    application_insights = lookup(var.resource_names, "application_insights", null)
    app_service_plan     = lookup(var.resource_names, "app_service_plan", null)
    key_vault            = lookup(var.resource_names, "key_vault", null)
    servicebus_namespace = lookup(var.resource_names, "servicebus_namespace", null)
    storage_account      = lookup(var.resource_names, "storage_account", null)
    virtual_network      = lookup(var.resource_names, "virtual_network", null)
  }
}