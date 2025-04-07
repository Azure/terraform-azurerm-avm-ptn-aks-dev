
terraform {
  required_providers {
    azapi = {
      source = "Azure/azapi"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = ""
}

provider "azapi" {
}
resource "azapi_resource" "registry_this" {}
resource "azapi_resource" "managedCluster_this" {}
resource "azapi_resource" "roleAssignment_acr" {}
resource "azapi_resource" "userAssignedIdentity_aks_0" {}
