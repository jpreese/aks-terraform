locals {
  cluster_name = "${var.prefix}-aks"
  agents_resource_group_name = "MC_${azurerm_resource_group.aks.name}_${local.cluster_name}_${azurerm_resource_group.aks.location}"
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "aks" {
  name = "${var.prefix}-aks-rg"
  location = "${var.location}"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${local.cluster_name}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.aks.name}"
  dns_prefix          = "${var.prefix}"

  agent_pool_profile {
    name            = "nodepool"
    count           = "${var.agents_count}"
    vm_size         = "${var.agents_size}"
    os_type         = "Linux"
    os_disk_size_gb = "${var.agents_disk_size}"
  }

  service_principal {
    client_id     = "${azuread_service_principal.aks.application_id}"
    client_secret = "${azuread_service_principal_password.aks.value}"
  }

  tags = "${var.tags}"
}

resource "azuread_application" "aks" {
  name = "${var.service_principal_name}"
}

resource "azuread_service_principal" "aks" {
  application_id = "${azuread_application.aks.application_id}"
}

resource "random_string" "aks" {
  length  = 16
  special = true

  keepers = {
    service_principal = "${azuread_service_principal.aks.id}"
  }
}

resource "azuread_service_principal_password" "aks" {
  service_principal_id = "${azuread_service_principal.aks.id}"
  value                = "${random_string.aks.result}"
  end_date             = "${timeadd(timestamp(), "8760h")}"

  lifecycle {
    ignore_changes = ["end_date"]
  }
}

resource "random_uuid" "aks" { }

resource "azurerm_role_definition" "aks" {
  role_definition_id = "${random_uuid.aks.result}"
  name               = "aks_service_principal_role"
  scope              = "${data.azurerm_subscription.current.id}"
  description        = "This role provides the required permissions needed to manage AKS"

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

data "azurerm_resource_group" "agents" {
  name = "${local.agents_resource_group_name}"

  depends_on = [
    "azurerm_kubernetes_cluster.aks",
  ]
}

resource "azurerm_role_assignment" "aks" {
  scope                = "${data.azurerm_resource_group.agents.id}"
  role_definition_name = "${azurerm_role_definition.aks.name}"
  principal_id         = "${azuread_service_principal.aks.id}"
}
