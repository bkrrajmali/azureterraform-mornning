terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
    subscription_id = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

  features {}

}

resource "azurerm_resource_group" "rg1" {
  for_each = {
    "dc1apps" = "eastus"
    "dc2apps" = "westus"
    "dc3apps" = "centralus"
  }
  name     = "${each.key}-rg"
  location = each.value
}

