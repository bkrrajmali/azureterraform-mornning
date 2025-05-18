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
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_resource_group" "myrg" {
  name     = "myrg-1"
  location = "East US"
}

resource "azurerm_virtual_network" "myvnet1" {
  name                = "myvnet1"
  resource_group_name = azurerm_resource_group.myrg.name
  location            = azurerm_resource_group.myrg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "mysubnet" {
  name                 = "mysubnet1"
  resource_group_name  = azurerm_resource_group.myrg.name
  virtual_network_name = azurerm_virtual_network.myvnet1.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "mypublic1" {
  name                = "mypublicip1"
  resource_group_name = azurerm_resource_group.myrg.name
  location            = azurerm_resource_group.myrg.location
  allocation_method   = "Static"

}


resource "azurerm_network_interface" "mynic1" {
  name                = "mynic1"
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mysubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mypublic1.id

  }
}

resource "azurerm_network_security_group" "mynsg1" {
  name                = "amynsg1"
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_subnet_network_security_group_association" "mysubnetnsgassociation" {
  subnet_id                 = azurerm_subnet.mysubnet.id
  network_security_group_id = azurerm_network_security_group.mynsg1.id

}

resource "azurerm_linux_virtual_machine" "myvm1" {
  name                = "myvm1"
  resource_group_name = azurerm_resource_group.myrg.name
  location            = azurerm_resource_group.myrg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  admin_password      = "Password1234!"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.mynic1.id

  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}