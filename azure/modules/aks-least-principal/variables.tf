variable "prefix" {
  description = "The prefix for the resources created in the specified Azure Resource Group"
  default     = "cluster"
}

variable "location" {
  description = "The location for the AKS deployment"
  default     = "eastus"
}

variable "service_principal_name" {
  description = "The name of the service principal to create for the AKS cluster"
  default     = "aks_service_principal"
}

variable "agents_count" {
  description = "The number of Agents that should exist in the Agent Pool"
  default     = 1
}

variable "agents_size" {
  description = "The default virtual machine size for the Kubernetes agents"
  default     = "Standard_DS2_v2"
}

variable "agents_disk_size" {
  description = "The default disk size for the virtual machine running the Kubernetes agents"
  default     = "30"
}

variable "address_space" {
  description = "Specifies the address space for the virtual network"
  default = ["10.1.0.0/16"]
}

variable "address_prefix" {
  description = "Specifies the address prefix for the subnet"
  default = "10.1.0.0/24"
}

variable "tags" {
  description = "The tags to be associated with the AKS resources"
  default     = {}
}
