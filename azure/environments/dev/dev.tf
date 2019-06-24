# The environment definition module is a simple entrypoint to define
# an AKS environment.
module "environment-definition" {
  source   = "../../modules/environment-definition"
  prefix   = "k2"
  env      = "dev"
  location = "eastus"
}
