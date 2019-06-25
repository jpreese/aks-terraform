resource "azuread_application" "sp" {
  name = "${var.name}"
}

resource "azuread_service_principal" "sp" {
  application_id = "${azuread_application.sp.application_id}"
}

resource "random_string" "sp" {
  length  = 16
  special = true

  keepers = {
    service_principal = "${azuread_service_principal.sp.id}"
  }
}

resource "azuread_service_principal_password" "sp" {
  service_principal_id = "${azuread_service_principal.sp.id}"
  value                = "${random_string.sp.result}"
  end_date             = "${timeadd(timestamp(), "${var.duration}")}"

  lifecycle {
    ignore_changes = ["end_date"]
  }
}
