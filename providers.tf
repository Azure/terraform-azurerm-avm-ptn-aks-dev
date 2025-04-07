provider "azurerm" {
  subscription_id = data.azapi_client_config.current.subscription_id
  features {
  }
}

data "azapi_client_config" "current" {}
