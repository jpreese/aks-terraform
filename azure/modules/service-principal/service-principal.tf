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

resource "azuread_service_principal_password" "service_principal_password" {
  service_principal_id = "${azuread_service_principal.service_principal.id}"
  value                = "${random_string.service_principal_random_password.result}"

  end_date             = "${timeadd(timestamp(), "8760h")}"

  # Ignore end date changes, at least for now during development.
  # Maybe have it change everytime in the wild?
  lifecycle {
    ignore_changes = ["end_date"]
  }

  provisioner "local-exec" {
    command = "sleep 60"
  }
}
