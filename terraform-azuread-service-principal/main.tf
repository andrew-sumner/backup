terraform {
  required_version = ">=0.14.0"

  required_providers {
    azuread = ">=2.7.0"
  }
}

# NOTE:
# 1. Currently no support for setting application id uri (this is set when create azure function manually with AAD authentication, doesn't seem to be required)
#    https://github.com/hashicorp/terraform-provider-azuread/issues/282

# 2. To find GUIDs for API Permissions...
#   a. Manually add them through Azure Portal
#   b. Open the "Manifest" tab
#   c. Find each "resourceAppId" and "resourceAccess" > "id" combination
#   d. You'll need to guess what API Permission these GUIDs belong to
#
# # Microsoft Graph
# required_resource_access {
#   resource_app_id = "00000003-0000-0000-c000-000000000000"
#
#   # User.Read
#   resource_access {
#     id = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
#     type = "Scope"
#   }
# }
#
# # Azure Key Vault
# required_resource_access {
#   resource_app_id = "cfa8b339-82a2-471a-a3c9-0fc0be7a4093"

#   # user_impersonation
#   resource_access {
#     id = "f53da476-18e3-4152-8e01-aec403e6edc0"
#     type = "Scope"
#   }
# }
#
# # Dynamics CRM
# required_resource_access {
#   resource_app_id = "00000007-0000-0000-c000-000000000000"

#   # user_impersonation
#   resource_access {
#     id = "78ce3f0f-a1ce-49c2-8cde-64b5c0896db4"
#     type = "Scope"
#   }
# }


resource "azuread_application" "app_spn" {
  display_name = var.display_name
  owners       = var.owners

  web {
    redirect_uris = var.redirect_uris

    implicit_grant {
      access_token_issuance_enabled = false
    }
  }

  dynamic "required_resource_access" {
    for_each = (var.required_resource_access)
    content {
      resource_app_id = required_resource_access.value["resource_app_id"]

      dynamic "resource_access" {
        for_each = (required_resource_access.value["resource_access"])
        content {
          id   = resource_access.value["id"]
          type = resource_access.value["type"]
        }
      }
    }
  }
}

resource "azuread_application_password" "app_spn" {
  application_object_id = azuread_application.app_spn.id
  display_name          = var.password_display_name
  end_date              = var.password_expiry_date

  depends_on = [azuread_application.app_spn]
}

resource "azuread_service_principal" "app_spn" {
  application_id               = azuread_application.app_spn.application_id
  app_role_assignment_required = false
  owners                       = var.owners
}
