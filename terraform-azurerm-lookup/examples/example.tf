resource "random_string" "suffix" {
  length  = 5
  special = false
}

module "example_resource_group" {
  source      = "git::https://stash.westpac.co.nz/scm/cp/terraform-azurerm-resource-group.git?ref=azurermV3"
  name        = "example-lookup-${random_string.suffix.result}-rg"
  location    = "australiaeast"
  salary_id   = "M809808"
  environment = "Test"
  app_owner   = "Miguel Juan"
  app_id      = "ID1010"
  squad_name  = "Cloud Compute"
  squad_code  = "2666"
}

module "lookup" {
  source = "/modules"

  resource_names = {
    resource_group = module.example_resource_group.resource_group.name
  }

  depends_on = [
    module.example_resource_group
  ]
}

output "resources" {
  value = module.lookup
}
