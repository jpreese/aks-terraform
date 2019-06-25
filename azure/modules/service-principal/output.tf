output "id" {
    value = "${azuread_service_principal.sp.id}"
}

output "application_id" {
  value = "${azuread_service_principal.sp.application_id}"
}

output "client_secret" {
  value = "${azuread_service_principal_password.sp.value}"
}
