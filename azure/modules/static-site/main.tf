terraform {
  required_providers {
    azurerm  = ">= 1.28.0"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.name}-rg"
  location = "${var.location}"
  tags     = "${var.tags}"
}

resource "azurerm_storage_account" "storage" {
    name                = "${var.name}data"
    resource_group_name = "${azurerm_resource_group.rg.name}"

    location                 = "${azurerm_resource_group.rg.location}"
    account_tier             = "Standard"
    account_replication_type = "LRS"

    network_rules {
        ip_rules = ["65.52.204.238", "157.56.10.150"]
    }

    tags = "${var.tags}"

    # https://github.com/terraform-providers/terraform-provider-azurerm/issues/1903
    #provisioner "local-exec" {
    #    command = "az storage blob service-properties update --account-name ${azurerm_storage_account.storage.name} --static-website --index-document index.html --404-document 404.html"
    #}
}

