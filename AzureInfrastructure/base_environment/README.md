# Azure Infrastructure

## Introduction

Creates the base resources required within an Azure Resource Group for the ICE Project.

This uses workspaces to manage the envrionments from dev through to production.

## Getting Started

terraform init
terrafom workspace select/new ...
terraform apply

## Contribute

Developers are free to stand up new development and test resource groups by creating a new workspace and envrionment file. 

Any Changes to those resources will need to be co-ordinated through the IT Crowd as changes will need to be applied to all environments once it has been tested.

## Current Migration

tf state mv azurerm_application_insights.main module.app_insights.azurerm_application_insights.main
tf state rm module.app_registration.random_password.app_spn
