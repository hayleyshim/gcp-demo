variable "project" {
  type = string
}

variable "region" {
  type    = string
  default = "asia-northeast3"
}

variable "zone" {
  type    = string
  default = "asia-northeast3-a"
}


variable "name" {
  type = string
}

variable "network" {
  type    = string
  default = "default"
}

variable "vm-type" {
  type    = string
  default = "f1-micro"
}

variable "vm-startup-script" {
  type    = string
  default = "apt update && apt -y install apache2 && echo '<html><body><p>Linux startup script added directly.</p></body></html>' > /var/www/html/index.html"
}

variable "vm-image" {
  type    = string
  default = "ubuntu-1804-bionic-v20200317"
}

variable "backend-port" {
  type = number
}

variable "frontend-port" {
  type = number
}
/*
variable "source-ranges" {
  type    = list(string)
  default = ["35.191.0.0/16", "130.211.0.0/22"]
}*/

variable "ip_protocol" {
  type    = string
  default = "tcp"
}

variable "service_accounts" {
  description = "Service account emails associated with the instances to allow SSH from IAP. Exactly one of service_accounts or network_tags should be specified."
  type        = list(string)
  default     = []
}

variable "instance_name" {
  type    = string
  default = "vpn-test"
} 

variable "classic_vpn_ext_gateway_ip" {
   type    = string
   default = "10.10.10.1/32"
}

variable "classic_vpn_shared_secret" {
   type    = string
   default = "K0p1Cl0ud"
}

variable "classic_vpn_router_interface_ip_range" {
   type    = string
   default = "169.254.2.1/30"
}

variable "classic_vpn_router_peer_ip_address" {
   type    = string
   default = "169.254.2.2"
}

/*
variable "billing_account_id" {
    type    = string

}

variable "classic_vpn_folder_id" {
    type    = string

}*/