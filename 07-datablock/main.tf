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
  name                = "myvnet1"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "mysubnet" {
  name                 = "mysubnet1"
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.myvnet1.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "mypublic1" {
  name                = "mypublicip1"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  allocation_method   = "Static"

}


resource "azurerm_network_interface" "mynic1" {
  name                = "mynic1"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mysubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mypublic1.id

  }
}

resource "azurerm_network_security_group" "mynsg1" {
  name                = "amynsg1"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

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

data "azurerm_key_vault" "existing" {
  name                = "azkeydemovault123"
  resource_group_name = "azkeydemovault"
}

data "azurerm_key_vault_secret" "vm_password" {
  name         = "azureadmin"
  key_vault_id = data.azurerm_key_vault.existing.id
}

# resource "azurerm_linux_virtual_machine" "myvm1" {
#   name                = "myvm1"
#   resource_group_name = azurerm_resource_group.rg1.name
#   location            = azurerm_resource_group.rg1.location
#   size                = "Standard_B1s"
#   admin_username      = "azureadmin"
#   admin_password      = data.azurerm_key_vault_secret.vm_password.value
#   network_interface_ids = [
#     azurerm_network_interface.mynic1.id
#   ]

#   os_disk {
#     name = "myosdisk1"  
#     caching              = "ReadWrite"
#     create_option        = "FromImage"
#     managed_disk_type    = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "UbuntuServer"
#     sku       = "18.04-LTS"
#     version   = "latest"
#   }
# }

resource "azurerm_virtual_machine" "main" {
  name                  = "Vm1"
  location              = azurerm_resource_group.rg1.location
  resource_group_name   = azurerm_resource_group.rg1.name
  network_interface_ids = [azurerm_network_interface.mynic1.id]
  vm_size               = "Standard_B1s"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "azureadmin"
    admin_password = data.azurerm_key_vault_secret.vm_password.value
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}