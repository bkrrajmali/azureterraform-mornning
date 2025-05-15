terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  subscription_id = "202d4be6-e0dd-4b9e-84b7-e235d53271a8"
  features {}

}

resource "random_string" "myrandom" {
  length = 8
  special = false
  upper = false
}