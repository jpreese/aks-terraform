output "service_principal_id" {
  value = "${azuread_service_principal.aks.id}"
}

output "service_principal_client_id" {
  value = "${azuread_service_principal.aks.application_id}"
}

output "service_principal_client_secret" {
  value = "${azure_service_principal_password.aks.value}"
}

output "service_principal_role" {
  value = "service_principal_role"
}
