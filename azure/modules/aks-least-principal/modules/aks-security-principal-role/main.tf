resource "azurerm_role_definition" "aks" {
  name               = "${var.name}"
  scope              = "${var.scope}"
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
    "${var.scope}",
  ]
}
