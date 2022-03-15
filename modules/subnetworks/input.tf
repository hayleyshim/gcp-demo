variable "subnetwork_name" {
  type = string
}

variable "cidr" {
  type = string
}


variable "subnetwork_region" {
  type = string
}


variable "network" {
  type = string
}

variable "depends_on_resoures" {
  type = list
}

variable "private_ip_google_access" {
  type = string
}
