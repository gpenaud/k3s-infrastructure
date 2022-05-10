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
# RESOURCES
# ==============================================================================

resource "lxd_volume" "volume" {
  name = var.node_name
  pool = var.storage_name
}

resource "lxd_container" "container" {
  name      = var.node_name
  image     = var.base_image
  ephemeral = false
  profiles  = var.profiles

  device {
    name = var.node_name
    type = "disk"

    properties = {
      path   = var.disk_root_path
      source = lxd_volume.volume.name
      pool   = var.storage_name
    }
  }
}

resource "lxd_container_file" "authorized_keys" {
  container_name     = var.node_name
  target_file        = "/home/ubuntu/.ssh/authorized_keys"
  source             = var.user_public_key
  mode               = "0644"
  create_directories = true

  depends_on = [
    lxd_container.container
  ]
}
