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
    path = "tfstates/container.tfstate"
  }
}

# ==============================================================================
# DATA
# ==============================================================================

data "terraform_remote_state" "storage" {
  backend = "local"
  config = {
    path = "./tfstates/storage.tfstate"
  }
}

# ==============================================================================
# RESOURCES
# ==============================================================================

module "container" {
  count          = length(var.containers)
  source         = "./modules/container"
  storage_name   = data.terraform_remote_state.storage.outputs.storage_name
  node_name      = element(var.containers, count.index)
  profiles       = ["k3s"]
  disk_root_path = "/opt/"
}

resource "lxd_profile" "k3s" {
  name = "k3s"

  device {
    name = "eth0"
    type = "nic"

    properties = {
      nictype = "bridged"
      parent  = var.network_name
    }
  }

  device {
    type = "disk"
    name = "root"

    properties = {
      pool = "default"
      path = "/"
    }
  }

  device {
    type = "disk"
    name = "aadisable"

    properties = {
      path   = "/sys/module/apparmor/parameters/enabled"
      source = "/dev/null"
    }
  }

  device {
    type = "disk"
    name = "kmsg"

    properties = {
      path   = "/dev/kmsg"
      source = "/dev/kmsg"
    }
  }

  config = {
    "linux.kernel_modules" = "overlay,nf_nat,ip_tables,ip6_tables,netlink_diag,br_netfilter,xt_conntrack,nf_conntrack,ip_vs,vxlan"
    "raw.lxc"              = file("${path.module}/files/lxc-profile.conf")
  }
}
