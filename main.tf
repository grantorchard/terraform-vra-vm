# ---------------------------------------------------------------------------------------------------------------------
# PROVIDER CONFIG
# Setup connections to the respective API endpoints.
# ---------------------------------------------------------------------------------------------------------------------


provider vra {
  url           = var.vra_url
  refresh_token = var.vra_refresh_token
}

provider bigip {
  address  = var.bigip_url
  username = var.bigip_username
  password = var.bigip_password
}

# ---------------------------------------------------------------------------------------------------------------------
# vRA Data Sources
# Existing items that we will interact with as part of provisioning.
# ---------------------------------------------------------------------------------------------------------------------


data vra_project "this" {
  name = var.project_name
}

data "vra_network" "this" {
  name = var.network_name
}

# ---------------------------------------------------------------------------------------------------------------------
# RANDOM ID
# Used for random elements in name generation.
# ---------------------------------------------------------------------------------------------------------------------


resource random_id "this" {
  byte_length = 8
}

# ---------------------------------------------------------------------------------------------------------------------
# vRA Machine
# Provisions a VM without the need for an existing Blueprint.
# ---------------------------------------------------------------------------------------------------------------------

resource "vra_deployment" "this" {
  name        = "${var.name_prefix}-${random_id.this.hex}"
  description = ""
  project_id  = data.vra_project.this.id
}


resource "vra_machine" "this" {
  count         = length(var.ip_addresses)
  name          = "${var.name_prefix}-${count.index}"
  description   = var.machine_description
  project_id    = data.vra_project.this.id
  image         = var.image
  flavor        = var.flavor
  deployment_id = vra_deployment.this.id

  nics {
    network_id = data.vra_network.this.id
    addresses  = [var.ip_addresses[count.index]]
  }

  constraints {
    mandatory  = true
    expression = var.tags
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# f5 CONFIGURATION
# Create an LB pool for the VMs provisioned by vRA.
# ---------------------------------------------------------------------------------------------------------------------


resource bigip_ltm_node "this" {
  count            = length(var.ip_addresses)
  name             = "/Common/${var.name_prefix}-${count.index}"
  address          = var.ip_addresses[count.index]
  connection_limit = "0"
  dynamic_ratio    = "1"
  monitor          = "/Common/icmp"
  description      = ""
  rate_limit       = "disabled"
}

resource bigip_ltm_pool "this" {
  name                = "/Common/${var.name_prefix}-pool"
  load_balancing_mode = "round-robin"
  description         = ""
  monitors            = ["/Common/https"]
  allow_snat          = "yes"
  allow_nat           = "yes"
}

resource bigip_ltm_pool_attachment "this" {
  count = 3
  pool  = bigip_ltm_pool.this.name
  node  = "${bigip_ltm_node.this[count.index].name}:443"
}

resource bigip_ltm_virtual_server "this" {
  name                       = "/Common/${var.virtual_server_name}"
  destination                = var.virtual_server_ip
  description                = var.virtual_server_description
  port                       = var.virtual_server_port
  pool                       = bigip_ltm_pool.this.id
  profiles                   = ["/Common/serverssl"]
  source_address_translation = "automap"
  translate_address          = "enabled"
  translate_port             = "enabled"
}