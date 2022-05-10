
variable "node_name" {
  description = "the node name"
  default     = "controlplane-01"
}

variable "base_image" {
  description = "the base image"
  default     = "ubuntu:18.04"
}

variable "profiles" {
  description = "the profiles used by the container"
  default = [
    "node"
  ]
}

variable "disk_root_path" {
  description = "the disk root path"
  default     = "/opt/"
}

variable "user_public_key" {
  description = "the user ssh public key"
  default     = "/home/gpenaud/.ssh/id_rsa.pub"
}

variable "storage_name" {
  description = "the storage pool name"
  default     = "default"
}
