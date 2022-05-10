# ==============================================================================
# network
# ==============================================================================

variable "network_name" {
  description = "the network name"
  default     = "k8s"
}

variable "network_domain" {
  description = "the domain name"
  default     = "k8s"
}

variable "network_cidr" {
  description = "network cidr"
  default     = "10.101.0.1/24"
}

# ==============================================================================
# storage
# ==============================================================================

variable "storage_pool_name" {
  description = "the storage pool name"
  default     = "k8s"
}

variable "storage_pool_type" {
  description = "the storage pool type"
  default     = "dir"
}
