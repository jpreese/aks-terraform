# The environment definition module pieces together all of the required resources
# to build an AKS environment.

module "resource_group" {
  source                    = "../resource-group"
  prefix                    = "${var.prefix}"
  env                       = "${var.env}"
  location                  = "${var.location}"
  name                      = "aksresourcegroup"
}

module "aks" {
  source                = "../aks"
  prefix                = "${var.prefix}"
  env                   = "${var.env}"
  location              = "${var.location}"
  resource_group_name   = "${module.resource_group.resource_group_name}"
  cluster_name          = "akscluster"
  dns_prefix            = "${var.prefix}"
  agent_count           = "2"
  agent_pool_name       = "kubenode"
  vm_size               = "Standard_A4m_v2"
  os_disk_size_gb       = "30"
}
