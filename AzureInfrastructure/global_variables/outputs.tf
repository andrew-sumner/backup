output "azure" {
  value = lower(var.azure_tenant) == "prod" ? local.prod_tenant : local.test_tenant
}

output "prefix" {
  value = local.prefix
}

output "resource_names" {
  value = local.resource_names
}

output "shared_resource_names" {
  value = local.shared_resource_names
}

output "tags" {
  value = local.tags
}