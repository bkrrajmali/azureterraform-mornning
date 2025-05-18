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
  subscription_id = "xxxxx-xxxx-xxxx-xxxx-xxx-xxx-xxx"
  features {}

}

