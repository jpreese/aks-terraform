variable "name" {
  description = "The name of the service principal to create"
}

variable "duration" {
  description = "The duration the service principal will be good for (e.g. 1h)"
  default     = "8760h"
}
