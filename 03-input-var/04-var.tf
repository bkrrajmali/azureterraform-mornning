variable "resource_group_name" {
  description = "This is Resource Group Name"
  type        = string
  default     = "demo-rg"
}

variable "resource_group_location" {
  description = "This is Location"
  type        = string
  default     = "eastus"
}

variable "virtual_network_name" {
  description = "This is Vnet Name"
  type        = string
  default     = "demovnet"
}

variable "address_space" {
  description = "This is Address Space"
  type        = list(string)
  default     = ["10.0.0.0/16"]

}