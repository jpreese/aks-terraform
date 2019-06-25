data "azurerm_subscription" "current" { }

data "azurerm_role_definition" "owner" {
  name = "Owner"
}

resource "azuread_group" "owners" {
    name = "${data.azurerm_subscription.current.display_name} - Owners"
}

resource "azurerm_role_assignment" "owners" {
  scope              = "${data.azurerm_subscription.current.id}"
  role_definition_id = "${data.azurerm_role_definition.owner.id}"
  principal_id       = "${azuread_group.owners.id}"
}
