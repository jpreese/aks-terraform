resource "azuread_application" "service_principal_app" {
  name = "${var.prefix}-${var.env}-${var.name}-app"
}

resource "azuread_service_principal" "service_principal" {
  application_id = "${azuread_application.service_principal_app.application_id}"
}

resource "random_string" "service_principal_random_password" {
  length  = 16
  special = true

  keepers = {
    service_principal = "${azuread_service_principal.service_principal.id}"
  }
}

resource "azuread_service_principal_password" "service_principal" {
  service_principal_id = "${azuread_service_principal.service_principal.id}"
  value                = "${random_string.service_principal_random_password.result}"

  end_date             = "${timeadd(timestamp(), "8760h")}"

  # Ignore end date changes, at least for now during development.
  # Maybe have it change everytime in the wild?
  lifecycle {
    ignore_changes = ["end_date"]
  }

  # https://github.com/terraform-providers/terraform-provider-azurerm/issues/3595
  provisioner "local-exec" {
    command = "sleep 30"
  }
}

data "azurerm_subscription" "current" {}

resource "azurerm_role_definition" "service_principal_role" {
  name        = "service_principal_role"
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

resource "azurerm_role_assignment" "service_principal_role_assignment" {
  scope                = "${module.resource_group.resource_group.id}"
  role_definition_name = "${azurerm_role_definition.service_principal_role.name}"
  principal_id         = "${azuread_service_principal.service_principal.id}"
}
