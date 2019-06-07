# The environment definition module pieces together all of the required resources
# to build an AKS environment.

module "aks" {
  source                = "../aks"
  prefix                = "${var.prefix}"
  env                   = "${var.env}"
  location              = "${var.location}"
  cluster_name          = "akscluster"
  dns_prefix            = "${var.prefix}"
  agent_count           = "2"
  agent_pool_name       = "kubenode"
  vm_size               = "Standard_DS2_v2"
  os_disk_size_gb       = "30"
}
