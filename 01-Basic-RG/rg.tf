# resource "azurerm_resource_group" "rg1" {
#   name     = "rg-${random_string.myrandom.id}"
#   location = "East US"
#   tags = {
#     Environment = "Demo"
#     Owner       = "IT"
#   }
# }

resource "azurerm_resource_group" "rg" {
  count = 3
  name = "rg-0${count.index+1}"
  location = "East US"
}

resource "azurerm_virtual_network" "vnet" {
 count = 3
 name = "vnet-0${count.index+1}"
 resource_group_name = azurerm_resource_group.rg[count.index].name
 address_space = ["10.${count.index}.0.0/16"]
 location = azurerm_resource_group.rg[count.index].location
}

resource "azurerm_subnet" "subnet" {
  count = 9
  name="subnet-${floor(count.index/3)+1}-${count.index%3+1}"
  resource_group_name = azurerm_resource_group.rg[floor(count.index/3)].name
  virtual_network_name =azurerm_virtual_network.vnet[floor(count.index/3)].name
  address_prefixes = ["10.${floor(count.index/3)}.${count.index%3+1}.0/24"]
}


