variable "azure_tenant" {
  type        = string
  description = "Purpose of the environment"

  validation {
    condition     = contains(["test", "prod"], var.azure_tenant)
    error_message = "The azure_tenant must be either 'test or prod'."
  }
}

variable "environment_name" {
  type        = string
  description = "Name of the environment"
}
