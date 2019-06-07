locals {
  aks_name = "${var.prefix}-${var.env}-${var.cluster_name}"
  aks_environment = "${var.prefix}-${var.env}"
}

module "aks_resource_group" {
  source                    = "../resource-group"
  prefix                    = "${var.prefix}"
  env                       = "${var.env}"
  location                  = "${var.location}"
  name                      = "aksresourcegroup"
}

module "aks_service_principal" {
  source       = "../service-principal"
  prefix       = "${var.prefix}"
  env          = "${var.env}"
  name         = "aks_service_principal"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${local.aks_name}"
  location            = "${var.location}"
  resource_group_name = "${module.aks_resource_group.resource_group_name}"
  dns_prefix          = "${var.dns_prefix}"

  agent_pool_profile {
    name            = "${var.agent_pool_name}"
    count           = "${var.agent_count}"
    vm_size         = "${var.vm_size}"
    os_type         = "Linux"
    os_disk_size_gb = "${var.os_disk_size_gb}"
  }

  service_principal {
    client_id     = "${module.aks_service_principal.service_principal_client_id}"
    client_secret = "${module.aks_service_principal.service_principal_client_secret}"
  }

  tags = {
    Name        = "${local.aks_name}"
    Environment = "${local.aks_environment}"
    Terraform   = "true"
  }
}

data "azurerm_subscription" "current" {}

resource "azurerm_role_definition" "aks_role" {
  name        = "aks_role"
  scope       = "${data.azurerm_subscription.current.id}"
  description = "This role provides the required permissions needed by Kubernetes to: Manager VMs, Routing rules, Mount azure files and Read container repositories"

  permissions {
    actions = [
      "Microsoft.Compute/virtualMachines/read",
      "Microsoft.Compute/virtualMachines/write",
      "Microsoft.Compute/disks/write",
      "Microsoft.Compute/disks/read",
      "Microsoft.Network/loadBalancers/write",
      "Microsoft.Network/loadBalancers/read",
      "Microsoft.Network/routeTables/read",
      "Microsoft.Network/routeTables/routes/read",
      "Microsoft.Network/routeTables/routes/write",
      "Microsoft.Network/routeTables/routes/delete",
      "Microsoft.Storage/storageAccounts/fileServices/fileShare/read",
      "Microsoft.ContainerRegistry/registries/read",
      "Microsoft.Network/publicIPAddresses/read",
      "Microsoft.Network/publicIPAddresses/write",
    ]

    not_actions = [
      "Microsoft.Compute/virtualMachines/*/action",
      "Microsoft.Compute/virtualMachines/extensions/*",
    ]
  }

  assignable_scopes = [
    "${data.azurerm_subscription.current.id}",
  ]
}

resource "azurerm_role_assignment" "role" {
  role_definition_name = "${azurerm_role_definition.aks_role.name}"
  scope                = "${module.aks_resource_group.resource_group_id}"
  principal_id         = "${module.aks_service_principal.service_principal_id}"
}

