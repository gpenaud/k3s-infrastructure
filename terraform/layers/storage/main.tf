# ==============================================================================
# PROVIDERS
# ==============================================================================

terraform {
  required_providers {
    lxd = {
      source = "terraform-lxd/lxd"
    }
  }
}

# ==============================================================================
# TERRAFORM
# ==============================================================================

terraform {
  backend "local" {
    path = "../../tfstates/storage.tfstate"
  }
}

# ==============================================================================
# RESOURCES
# ==============================================================================

resource "lxd_storage_pool" "k8s" {
  name   = var.storage_pool_name
  driver = var.storage_pool_type
  config = {
    source = "/var/lib/lxd/storage-pools/${var.storage_pool_name}"
  }
}
