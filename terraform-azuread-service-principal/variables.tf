variable "display_name" {
  type        = string
  description = "Full name of the service principal."
}

variable "owners" {
  type        = list(string)
  description = "A list of Azure AD Object IDs that will be granted ownership of the application, this should include the Enterprise Application Object ID of the deployment SPN so that it becomes an owner even if run by a user."
}

variable "required_resource_access" {
  type = list(object({
    resource_app_id = string
    resource_access = list(object({
      id   = string
      type = string
    }))
  }))
  description = "Collection describing the OAuth2.0 permission scopes and app roles that the application requires from the specified resource."
  default     = []
}

variable "password_display_name" {
  type        = string
  description = "Name to give to the secret."
  default     = "Secret"
}

variable "password_expiry_date" {
  type        = string
  description = "Expiry date for secret, defaults to never."
  default     = "2299-12-31T00:00:00Z" # Never
}

variable "redirect_uris" {
  type        = list(string)
  description = "A list of URLs where user tokens are sent for sign-in, or the redirect URIs where OAuth 2.0 authorization codes and access tokens are sent."
  default     = null
}