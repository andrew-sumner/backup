# Shared Resources

## Introduction

Creates a resource group and key vault where secrets can be stored for use as inputs to other terraform configurations.

The plan is to:

- have one vault in the test tennat and another in the prod tenant
- secrets will be added manually
- envrionment specific secrets should be prefixed with the name of the secret, eg example-clientsecret

## Getting Started

terraform init
terrafom workspace select/new ...
terraform apply

## Contribute

Developers are free to contribute but any changes should be co-ordinated through the IT Crowd.

## Migration

### From azuread provider 1.6.0 to 2.18.0
/subscriptions/a724b29b-ab3b-42dc-ab11-5c252397a687/resourcegroups/ice-shared-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/ice-graph-api-uai "resourcegroups" to be "resourceGroups"

group_membership_claims change "" to []
