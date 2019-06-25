locals {
  cluster_name = "${var.prefix}-aks"
  agents_resource_group_name = "MC_${azurerm_resource_group.aks.name}_${local.cluster_name}_${azurerm_resource_group.aks.location}"
}

data "azurerm_subscription" "current" {}


resource "azurerm_resource_group" "aks" {
  name = "${var.prefix}-aks-rg"
  location = "${var.location}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AKS VNET AND SUBNET
# ---------------------------------------------------------------------------------------------------------------------

resource "azurerm_virtual_network" "aks" {
  name                = "${local.cluster_name}-vnet"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.aks.name}"
  address_space       = "${var.address_space}"
}

resource "azurerm_subnet" "aks" {
  name                      = "${local.cluster_name}-subnet"
  resource_group_name       = "${azurerm_resource_group.aks.name}"
  virtual_network_name      = "${azurerm_virtual_network.aks.name}"
  address_prefix            = "${var.address_prefix}"

  # This field will be deprecated soon, but is required for now or the NSG assocation gets removed.
  # https://github.com/terraform-providers/terraform-provider-azurerm/issues/2178
  network_security_group_id = "${azurerm_network_security_group.aks.id}"

  # Ignore changes to route_table_id because if you make an association elsewhere this tries to clear it.
  # https://www.terraform.io/docs/providers/azurerm/r/subnet.html#route_table_id
  lifecycle {
    ignore_changes = [ "route_table_id" ]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# APPLY AKS NETWORK SECURITY GROUP RULES
# ---------------------------------------------------------------------------------------------------------------------

resource "azurerm_network_security_group" "aks" {
  name                      = "${local.cluster_name}-nsg"
  resource_group_name       = "${azurerm_resource_group.aks.name}"
  location                  = "${var.location}"
}

module "aks_security_group_rules" {
  source = "./modules/aks-security-group-rules"

  resource_group_name = "${azurerm_resource_group.aks.name}"
  network_security_group_name = "${azurerm_network_security_group.aks.name}"
}


# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SERVICE PRINCIPAL WITH LEAST PRIVILEGE
# ---------------------------------------------------------------------------------------------------------------------

module "service_principal" {
  source = "../service-principal"

  name = "AKS Service Principal"
}

module "aks_security_principal_role" {
  source = "./modules/aks-security-principal-role"

  name  = "AKS Manager"
  scope = "${data.azurerm_subscription.current.id}"
}

resource "azurerm_role_assignment" "aks" {
  scope                = "${data.azurerm_resource_group.agents.id}"
  role_definition_name = "${module.aks_security_principal_role.name}"
  principal_id         = "${module.service_principal.id}"
}

data "azurerm_resource_group" "agents" {
  name = "${local.agents_resource_group_name}"

  depends_on = [
    "azurerm_kubernetes_cluster.aks",
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE AKS CLUSTER USING THE SERVICE PRINCIPAL
# ---------------------------------------------------------------------------------------------------------------------

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${local.cluster_name}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.aks.name}"
  dns_prefix          = "${var.prefix}"

  agent_pool_profile {
    name            = "nodepool"
    count           = "${var.agents_count}"
    vm_size         = "${var.agents_size}"
    os_type         = "Linux"
    os_disk_size_gb = "${var.agents_disk_size}"
    vnet_subnet_id  = "${azurerm_subnet.aks.id}"
  }

  service_principal {
    client_id     = "${module.service_principal.application_id}"
    client_secret = "${module.service_principal.client_secret}"
  }

  network_profile {
    network_plugin = "azure"
  }

  tags = "${var.tags}"
}
