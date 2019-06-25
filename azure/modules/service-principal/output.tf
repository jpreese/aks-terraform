output "client_id" {
  value = "${azuread_service_principal.sp.id}"
}

output "client_secret" {
  value = "${azuread_service_principal_password.sp.value}"
}
