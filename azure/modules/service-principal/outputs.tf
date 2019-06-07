output "service_principal_id" {
  value = "${azuread_service_principal.service_principal.id}"
}

output "service_principal_client_id" {
  value = "${azuread_service_principal.service_principal.application_id}"
}

output "service_principal_client_secret" {
  sensitive = true
  value     = "${random_string.service_principal_random_password.result}"
}
