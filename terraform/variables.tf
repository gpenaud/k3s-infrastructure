
variable "network_name" {
  description = "name of the network to use"
  default     = "k8s"
}

variable "containers" {
  description = "list of containers to create"
  default = [
    "controlplane-01",
    "dataplane-01",
  ]
}
