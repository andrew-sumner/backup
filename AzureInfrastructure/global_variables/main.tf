terraform {

}

locals {
  # Information required for deploying to your test and prod subscriptions:
  # - tenant_id                       = The GUID of the tenant, you won't need to change this
  # - subscription_id                 = The GUID of the subscription
  # - default_resource_location       = Where to create the resources, if using D365 we recommend keeping the resources in 
  #                                     the same region 
  # - email_domain_name               = Used to build email address when creating D365 application user
  # - deployment_spn_name             = Name of the account used in your deployment pipeline, this service principal is 
  #                                     granted updated access to the keyvault so it can create secrets
  # - keyvault_contributor_group_name = AD Group that developers use to access the subscription (...-Contributor in test, ...-Reader in production)
  #                                     This group is granted reader access on the keyvaults

  test_tenant = {
    tenant_id                            = "cfa7edde-76be-4c5f-b8a8-92820462e497"
    subscription_id                      = "a724b29b-ab3b-42dc-ab11-5c252397a687" # D365 Integrated Customer Environment - Dev/Test
    default_resource_location            = "australiasoutheast"
    email_domain_name                    = "test.westpac.co.nz"
    deployment_spn_name                  = "ICE-AzureDeployment-Test"
    keyvault_contributor_group_name      = "CorpTestNZ-Access-AzureSubscriptions-ICE-Contributor"
    test_automation_keyvault_contributor = "CorpTestNZ-Access-AzureSubscriptions-ICE-Contributor"
    test_automation_keyvault_reader      = "CorpTestNZ-Access-AzureSubscriptions-ICE-Reader"
    ad_domain                            = "CorpTestNZ"
    ad_team_owner_email                  = "srv-d365-development@test.westpac.co.nz"
  }

  prod_tenant = {
    tenant_id                            = "e3d7352c-397e-4fdb-ac22-c9513142fc13"
    subscription_id                      = "18342d3c-56c1-445c-9870-ba61840e396d" # D365 Integrated Customer Environment - Prod
    default_resource_location            = "australiasoutheast"
    email_domain_name                    = "westpac.co.nz"
    deployment_spn_name                  = "ICE-AzureDeployment-Prod"
    keyvault_contributor_group_name      = "CorpNZ-Access-AzureSubscriptions-ICE-Contributor"
    test_automation_keyvault_contributor = "CorpNZ-Access-AzureSubscriptions-ICE-Contributor"
    test_automation_keyvault_reader      = "CorpNZ-Access-AzureSubscriptions-ICE-Reader"
    ad_domain                            = "CorpNZ"
    ad_team_owner_email                  = "srv-d365-development@westpac.co.nz"
  }

  # Prefix to apply resource names
  prefix = "ice"

  # Names of resources to create / lookup in an environment
  resource_names = {
    resource_group       = "${local.prefix}-${var.environment_name}-rg"
    application_insights = "${local.prefix}-${lower(var.environment_name)}-insights"
    app_service_plan     = "${local.prefix}-${lower(var.environment_name)}-plan"
    key_vault            = "${local.prefix}-${lower(var.environment_name)}-kv"
    servicebus_namespace = "${local.prefix}-${lower(var.environment_name)}-sbus"
    storage_account      = "${lower(local.prefix)}${lower(var.environment_name)}sa"
    # virtual_network      = "${local.prefix}-${lower(var.environment_name)}-vnet"
  }

  # Names of shared to create / lookup in each subscription
  shared_resource_names = {
    resource_group            = "${local.prefix}-shared-rg"
    key_vault                 = "${local.prefix}-shared-${var.azure_tenant}-kv"
    test_automation_key_vault = "${local.prefix}-tester-${var.azure_tenant}-kv"
    graph_api_identity        = "${local.prefix}-graph-api-uai"
  }

  # Default tags to apply to resources
  tags = {
    "Application ID"    = "908"     # From application inventory list in sharepoint
    "Salary ID"         = "M011759" # Product owner
    "Application Owner" = "Glen Bremner"
    "Squad Code"        = "2215" # From squad list in sharepoint
    "Squad Name"        = "ICE"
  }
}