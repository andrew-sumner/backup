<!-- Space: HOWC -->
<!-- Parent: Knowledge base -->
<!-- Parent: Terraform -->
<!-- Parent: Azure Modules -->
<!-- Title: terraform-azuread-service-principal -->
<!-- Label: Azure -->
<!-- Label: Cloud Terraform -->
<!-- Label: Terraform modules -->

![img](https://jenkins-cp.cloud.westpac.co.nz/job/Azure_Terraform_Module_Provider_V3/job/terraform-azuread-service-principal/job/azurermV3//badge/icon?)

## Azure Service Principal Terraform Module

### What does it do

This module creates an Azure AD app registration and service principal with all the required Westpac IT controls in place.

### Usage

To create a Serive Principal you need:

- Azure subscription
- Azurerm provider creds(i.e: client_id, client_secret, tenant_id, subscription_id)
- Necessary rights to create service pricipals, when the terraform configuration is being executed in a release pipeline the service princial it uses to authenticate into Azure must have the following API permissions: application.readwrite.ownedby.

**NOTE:**
> Ownership of the SPN gets problematic, the example below will make both the Pipeline SPN and a developer (if run locally) the owner of the SPN.
>
> If another developer tries to run it, this will attempt to remove the first developer (if added) and apply the current developer - which will fail as the developer has no rights to the SPN.
>
> A better approach may be to add all developers in the team (plus the pipeline SPN) in test environments, and only the pipeline SPN in production.

### Example Usage

Deploying to an existing Resource Group

```bash

data "azuread_service_principal" "deployment_spn" {
  display_name = "ICE-DevOpsPipeline-Test"
}

data "azuread_client_config" "current" {}

module "service_principal" {
  source       = "git::https://stash.westpac.co.nz/scm/cp/terraform-azuread-service-principal?ref=master"
  display_name = "ExampleSPN"
  # Pipeline SPN & current user
  owners = concat([data.azuread_service_principal.deployment_spn.object_id], [data.azuread_client_config.current.object_id])
}

output "azuread_application" {
  value = module.service_principal.azuread_application
}

output "azuread_service_principal" {
  value = module.service_principal.azuread_service_principal
}

output "secret" {
  value     = module.service_principal.azuread_application_password
  sensitive = true
}

```

### Guidlines used to create the module

Please refer to the official provider Documentation on possbile options and configurations.
[AZUREAD Application](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application)
[AZUREAD Service Principal](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal)

### Module Reference

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\\_terraform) | >=0.14.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\\_azuread) | >=2.7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\\_azuread) | >=2.7.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuread_application.app_spn](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_application_password.app_spn](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_password) | resource |
| [azuread_service_principal.app_spn](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_display_name"></a> [display\\_name](#input\\_display\\_name) | Full name of the service principal. | `string` | n/a | yes |
| <a name="input_owners"></a> [owners](#input\\_owners) | A list of Azure AD Object IDs that will be granted ownership of the application, this should include the Enterprise Application Object ID of the deployment SPN so that it becomes an owner even if run by a user. | `list(string)` | n/a | yes |
| <a name="input_password_display_name"></a> [password\\_display\\_name](#input\\_password\\_display\\_name) | Name to give to the secret. | `string` | `"Secret"` | no |
| <a name="input_password_expiry_date"></a> [password\\_expiry\\_date](#input\\_password\\_expiry\\_date) | Expiry date for secret, defaults to never. | `string` | `"2299-12-31T00:00:00Z"` | no |
| <a name="input_redirect_uris"></a> [redirect\\_uris](#input\\_redirect\\_uris) | A list of URLs where user tokens are sent for sign-in, or the redirect URIs where OAuth 2.0 authorization codes and access tokens are sent. | `list(string)` | `null` | no |
| <a name="input_required_resource_access"></a> [required\\_resource\\_access](#input\\_required\\_resource\\_access) | Collection describing the OAuth2.0 permission scopes and app roles that the application requires from the specified resource. | ```list(object({ resource_app_id = string resource_access = list(object({ id = string type = string })) }))``` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application"></a> [application](#output\\_application) | The app registration resource |
| <a name="output_application_password"></a> [application\\_password](#output\\_application\\_password) | The password for the application |
| <a name="output_service_principal"></a> [service\\_principal](#output\\_service\\_principal) | The service principal resource |

### Contribution

### Authors

- Andrew Sumner
