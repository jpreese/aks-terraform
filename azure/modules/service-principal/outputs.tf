output "service_principal_id" {
  value = "${azuread_service_principal.service_principal.id}"
}

output "service_principal_client_id" {
  value = "${azuread_service_principal.service_principal.application_id}"
}

output "service_principal_client_secret" {
  sensitive = true
  value     = "${azuread_service_principal_password.service_principal.value}"
}

output "service_principal_role" {
  value = "service_principal_role"
}
