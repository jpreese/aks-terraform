variable "name" {
  description = "Specifies the name of the static website."
  type        = "string"
}

variable "location" {
  description = "Specifies the Azure region for the resource group and contained resources."
  type        = "string"
}

variable "tags" {
  description = "Specifies tags to attach to the static site Azure resources."
  type        = "map"
  default     = {}
}
