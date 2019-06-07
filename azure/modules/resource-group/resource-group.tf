locals {
  resource_group_name  = "${var.prefix}-${var.env}-${var.name}-resourcegroup"
  resource_group_env   = "${var.prefix}-${var.env}"
}

resource "azurerm_resource_group" "resource_group" {
  name     = "${local.resource_group_name}"
  location = "${var.location}"

  tags = {
    Name        = "${local.resource_group_name}"
    Environment = "${local.resource_group_env}"
    Terraform   = "true"
  }
}
