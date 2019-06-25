resource "azurerm_network_security_rule" "inbound-1100" {
  name                        = "Allow-Internal-Inbound"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${var.network_security_group_name}"
  priority                    = 1100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_address_prefix       = "172.16.50.0/24"
  source_port_range           = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "*"
}

resource "azurerm_network_security_rule" "outbound-1300" {
  name                        = "Allow-Internal-Outbound"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${var.network_security_group_name}"
  priority                    = 1300
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_address_prefix       = "*"
  source_port_range           = "*"
  destination_address_prefix  = "10.10.0.0/16"
  destination_port_range      = "*"
}

resource "azurerm_network_security_rule" "outbound-4096" {
  name                        = "DenyAllOutbound"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${var.network_security_group_name}"
  priority                    = 4096
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_address_prefix       = "*"
  source_port_range           = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "*"
}
