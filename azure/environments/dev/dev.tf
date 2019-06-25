locals {
  location = "eastus"
  env      = "dev"
}

terraform {
  required_version = "~> 0.12.0"
}

provider "azurerm" {
  version         = "~> 1.30.0"
  subscription_id = "f0b6bb0f-46c4-4e8e-af26-b38a8c870dd2"
  tenant_id       = "18693b2c-1bc6-46c5-a191-9f1710667cba"
}

provider "azuread" {
  version         = "~> 0.3.1"
  subscription_id = "f0b6bb0f-46c4-4e8e-af26-b38a8c870dd2"
  tenant_id       = "18693b2c-1bc6-46c5-a191-9f1710667cba"
}

module "dev_subscription" {
  source   = "../../modules/subscription"
}

module "aks_least_principal" {
  source                = "../../modules/aks-least-principal"

  location              = "${var.location}"
  prefix                = "${var.env}"

  agents_count          = "2"
  agents_size           = "Standard_DS2_v2"
  agents_disk_size      = "30"
}
