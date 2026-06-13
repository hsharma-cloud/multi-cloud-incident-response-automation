resource "azurerm_resource_group" "main" {
  name     = "rg-multicloud-ir-dev"
  location = "East US"
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-multicloud-ir-dev"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}


resource "azurerm_subnet" "workload" {
  name                 = "subnet-workload-dev"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_network_security_group" "workload" {
  name                = "nsg-workload-dev"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}
