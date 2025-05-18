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
  subscription_id = "xxxxx-xxxx-xxxx-xxxx-xxx-xxx-xxx"
  features {}

}

resource "random_string" "myrandom" {
  length = 8
  special = false
  upper = false
}