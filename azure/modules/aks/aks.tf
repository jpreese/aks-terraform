locals {
  aks_name = "${var.prefix}-${var.env}-${var.cluster_name}"
  aks_environment = "${var.prefix}-${var.env}"
}

module "aks_service_principal" {
  source       = "../service-principal"
  prefix       = "${var.prefix}"
  env          = "${var.env}"
  name         = "aks_service_principal"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${local.aks_name}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  dns_prefix          = "${var.dns_prefix}"

  agent_pool_profile {
    name            = "${var.agent_pool_name}"
    count           = "${var.agent_count}"
    vm_size         = "${var.vm_size}"
    os_type         = "Linux"
    os_disk_size_gb = "${var.os_disk_size_gb}"
  }

  service_principal {
    client_id     = "${module.aks_service_principal.service_principal_client_id}"
    client_secret = "${module.aks_service_principal.service_principal_client_secret}"
  }

  tags = {
    Name        = "${local.aks_name}"
    Environment = "${local.aks_environment}"
    Terraform   = "true"
  }
}
