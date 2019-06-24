# The environment definition module pieces together all of the required resources
# to build an AKS environment.

module "site" {
  source = "../static-site"

  name = "mysite"
  location = "eastus"

  tags = {
    sometag    = "sometagvalue"
    anothertag = "anothertagvalue"
  }
}
