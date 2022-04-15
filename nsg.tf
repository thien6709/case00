resource "azurerm_resource_group" "nsg_rg" {
  name     = var.hub_nsg_rg_name
  location = var.location
}

resource "azurerm_network_security_group" "hub_mgmt_nsg" {
  name                = var.hub_mgmt_nsg_name
  location            = azurerm_resource_group.nsg_rg.location
  resource_group_name = azurerm_resource_group.nsg_rg.name
}

resource "azurerm_network_security_group" "spoke_web_nsg" {
  name                = var.spoke_web_nsg_name
  location            = azurerm_resource_group.nsg_rg.location
  resource_group_name = azurerm_resource_group.nsg_rg.name
}

