<!-- Space: HOWC -->
<!-- Parent: Knowledge base -->
<!-- Parent: Terraform -->
<!-- Parent: Azure Modules -->
<!-- Title: terraform-azurerm-lookup -->
<!-- Label: Azure -->
<!-- Label: Cloud Terraform -->
<!-- Label: Terraform modules -->

![img](https://jenkins-cp.cloud.westpac.co.nz/job/Azure_Terraform_Module_Provider_V3/job/terraform-azurerm-lookup/job/azurermV3//badge/icon?)

## Azure Lookup Terraform Module

### What does it do

This is a data only module that looks up a standard set of resources and returns them.

The module primarily targeted at the resources required to create Function and Logic Apps so is not expected to return information on all Azure resources in your environment.

It works best in an an environment setup following the guidelines of the template project, which is documented [here](https://confluence.westpac.co.nz/display/BUSINESS/Terraform+with+Azure). The source code for the template is [here](https://tfs.westpac.co.nz/WestpacCollection/Terraform/_git/Templates).

### Usage

To use this module you will need to know the names of the existing Azure resources you need to retrieve. All resources must belong to the same resource group.

Have a look at the code in <https://tfs.westpac.co.nz/WestpacCollection/Terraform/_git/Templates> for real examples of how to use this module.

### Example Usage

```bash

module "lookup" {
  source = "git::https://stash.westpac.co.nz/scm/cp/terraform-azure-lookup?ref=master"
  resource_names = {
    resource_group       = "example-rg"
    application_insights = "example-insights"
    app_service_plan     = "example-plan"
    key_vault            = "example-kv"
    servicebus_namespace = "example-sbus"
    storage_account      = "examplesa"
    virtual_network      = "example-vnet"
  }
}

output "resources" {
  value = module.lookup
}

```

### Module Reference

#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >=0.14.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm) | > 3.0.0 |

#### Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider_azurerm) | > 3.0.0 |

#### Modules

No modules.

#### Resources

| Name | Type |
|------|------|
| [azurerm_application_insights.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/application_insights) | data source |
| [azurerm_key_vault.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_service_plan.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/service_plan) | data source |
| [azurerm_servicebus_namespace.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/servicebus_namespace) | data source |
| [azurerm_storage_account.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account) | data source |
| [azurerm_subnet.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_subnet.private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_virtual_network.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

#### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_private_subnet_filter"></a> [private_subnet_filter](#input_private_subnet_filter) | RegEx to filter subnets with, e.g. "(?i)private.*" will perform a case insensitive search and return all subnets starting with 'General'. By default will return all subnets. | `string` | `null` | no |
| <a name="input_resource_names"></a> [resource_names](#input_resource_names) | The names of the resources to look up, if a name is null the resource will not be looked up. | `map(any)` | n/a | yes |
| <a name="input_subnet_filter"></a> [subnet_filter](#input_subnet_filter) | RegEx to filter subnets with, e.g. "(?i)delegated.*" will perform a case insensitive search and return all subnets starting with 'Delegated'. By default will return all subnets. | `string` | `null` | no |
| <a name="input_vnet_is_optional"></a> [vnet_is_optional](#input_vnet_is_optional) | If virtual network is optional, check that it exists before looking it up. This checks that the key vault is attached to a subnet before looking up the virtual network. | `bool` | `false` | no |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_service_plan"></a> [app_service_plan](#output_app_service_plan) | App service plan data object - if resource_names.app_service_plan parameter is not null |
| <a name="output_application_insights"></a> [application_insights](#output_application_insights) | Application insights data object - if resource_names.application_insights parameter is not null |
| <a name="output_key_vault"></a> [key_vault](#output_key_vault) | Key vault data object - if resource_names.key_vault parameter is not null |
| <a name="output_private_subnet"></a> [private_subnet](#output_private_subnet) | The first virtual network subnet matching the private_subnet_filter parameter, also requires resource_names.virtual_network parameter to be populated |
| <a name="output_resource_group"></a> [resource_group](#output_resource_group) | Resource group data object |
| <a name="output_servicebus_namespace"></a> [servicebus_namespace](#output_servicebus_namespace) | Servicebus namespace data object - if resource_names.servicebus_namespace parameter is not null |
| <a name="output_storage_account"></a> [storage_account](#output_storage_account) | Storage account data object - if resource_names.storage_account parameter is not null |
| <a name="output_subnets"></a> [subnets](#output_subnets) | List of virtual network subnets matching the subnet_filter parameter, also requires resource_names.virtual_network parameter to be populated |
| <a name="output_virtual_network"></a> [virtual_network](#output_virtual_network) | Virtual network data object - if resource_names.virtual_network parameter is not null |

### Contribution

### Authors

- Andrew Sumner
