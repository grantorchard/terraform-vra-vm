variable vra_url {
  type    = string
  default = "https://api.mgmt.cloud.vmware.com"
}

variable vra_refresh_token {
  type = string
}

variable bigip_url {
  type = string
}

variable bigip_username {
  type    = string
  default = "admin"
}

variable bigip_password {
  type = string
}

variable virtual_server_name {
  type = string
}

variable virtual_server_port {
  type    = string
  default = "443"
}

variable virtual_server_description {
  type    = string
  default = ""
}

variable virtual_server_ip {
  type = string
}

variable project_name {
  type    = string
  default = "Lab"
}

variable name_prefix {
  type    = string
  default = "tf"
}

variable ip_addresses {
  type = list
}

variable network_name {
  type = string
}

variable tags {
  type = string
}

variable flavor {
  type    = string
  default = "medium"
}

variable image {
  type    = string
  default = "ubuntu"
}

variable machine_description {
  type    = string
  default = ""
}