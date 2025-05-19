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
  name     = "rg1"
  location = "eastus"
}

resource "azurerm_virtual_network" "myvnet1" {
  name                = "vnet1"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  address_space       = ["10.0.0.0/16"]
}
resource "azurerm_subnet" "mysubnet1" {
  name                 = "mysubnet1"
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.myvnet1.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "mysubnet2" {
  name                 = "mysubnet2"
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.myvnet1.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "mypublic1" {
  name                = "mypublicip1"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  allocation_method   = "Static"
  depends_on = [ azurerm_virtual_network.myvnet1, azurerm_subnet.mysubnet1, azurerm_subnet.mysubnet2 ]
}
resource "azurerm_network_interface" "mynic1" {
  name                = "mynic1"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  ip_configuration {
    name                          = "myipconfig1"
    subnet_id                     = azurerm_subnet.mysubnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mypublic1.id
  }
}