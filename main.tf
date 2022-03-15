provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

provider "google-beta" {
  project = var.project
  region  = var.region
  zone    = var.zone
}



# creating the network
module "network" {
  source = "./modules/network"

  network_name = "network"
  auto_create_subnetworks = "false"
}

/*
# creating the public subnet
module "public_subnet" {
  source = "./modules/subnetworks"

  subnetwork_name = "public-subnetwork"
  cidr = "10.10.10.0/24"
  subnetwork_region = "asia-northeast3"
  network = module.network.network_name
  depends_on_resoures = [module.network]
  private_ip_google_access = "false"
}*/

# creating the private subnet - server
module "private_subnet" {
  source = "./modules/subnetworks"

  subnetwork_name = "private-subnetwork"
  cidr = "10.10.20.0/24"
  subnetwork_region = "asia-northeast3"
  network = module.network.network_name
  depends_on_resoures = [module.network]
  private_ip_google_access = "false"
}

/*
# creating the private subnet - db
module "private_subnet2" {
  source = "./modules/subnetworks"

  subnetwork_name = "private-subnetwork2"
  cidr = "10.10.30.0/24"
  subnetwork_region = "asia-northeast3"
  network = module.network.network_name
  depends_on_resoures = [module.network]
  private_ip_google_access = "false"
}*/



# create firewall rule with ssh access to the public instance/s
module "firewall_rule_ssh_all" {
  source = "./modules/firewall"

  firewall_rule_name = "ssh-instances"
  network = module.network.network_name
  protocol_type = "tcp"
  ports_types = null
  source_tags = null
  source_ranges = ["0.0.0.0/0"]
  target_tags = null
}

/*# create firewall rule to access only the public vm with icmp
module "firewall_rule_icmp_public" {
  source = "./modules/firewall"

  firewall_rule_name = "access-vm"
  network = module.network.network_name
  protocol_type = "icmp"
  ports_types = null
  source_tags = null
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["ncu-vm","ncu-analysis-vm" ]
}*/

/*# firwall rule for private instances
module "firewall_rule_private_vm" {
  source = "./modules/firewall"

  firewall_rule_name = "private-vm"
  network = module.network.network_name
  protocol_type = "icmp"
  ports_types = null
  source_tags = null
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["ncu-vm"]
}*/

# firwall rule for private instances
module "firewall_rule_private_vm2" {
  source = "./modules/firewall"

  firewall_rule_name = "private-vm-from-ncu"
  network = module.network.network_name
  protocol_type = "icmp"
  ports_types = null
  source_tags = ["ncu-vm"]
  source_ranges = null
  target_tags = ["ncu-analysis-vm"]
}

/*
# create the vm in public subnet
module "public_instance" {
  source = "./modules/instance"

  instance_name = "bastion"
  machine_type = "f1-micro"
  vm_zone = "asia-northeast3-a"
  network_tags = ["bastion", "test"]
  machine_image = "ubuntu-1804-bionic-v20200317"
  subnetwork = module.public_subnet.sub_network_name
  metadata_Name_value = "public_vm"
  
}*/

/*module "bastion-host" {
  source  = "terraform-google-modules/bastion-host/google"
  version = "4.1.0"
  # insert the 4 required variables here
}*/


/*
# create the vm in public subnet
module "private_instance" {
  source = "./modules/instance"

  instance_name = "saas-vm"
  machine_type = "f1-micro"
  vm_zone = "asia-northeast3-b"
  network_tags = ["saas-vm", "test"]
  machine_image = "ubuntu-1804-bionic-v20200317"
  subnetwork = module.private_subnet.sub_network_name
  metadata_Name_value = "private_vm"

}
*/



# create the vm in public subnet - 추가(vm)
module "private_instance2" {
  source = "./modules/instance"

  instance_name = "ncu-vm"
  machine_type = "f1-micro"
  vm_zone = "asia-northeast3-a"
  network_tags = ["ncu-vm", "test"]
  machine_image = "ubuntu-1804-bionic-v20200317"
  //subnetwork = module.private_subnet.sub_network_name

  //network    = module.network.self_link
  subnetwork = module.private_subnet.self_link
  metadata_Name_value = "private_vm"
  
}

# create the vm in public subnet - 추가(vm)
module "private_instance3" {
  source = "./modules/instance"

  instance_name = "ncu-analysis-vm"
  machine_type = "f1-micro"
  vm_zone = "asia-northeast3-a"
  network_tags = ["ncu-analysis-vm", "test"]
  machine_image = "ubuntu-1804-bionic-v20200317"
  //subnetwork = module.private_subnet.sub_network_name
  
  //network    = module.network.self_link
  subnetwork = module.private_subnet.self_link
  metadata_Name_value = "private_vm"
}

/*
# create the vm in public subnet - 추가(vm-db)
module "private_vm_db" {
  source = "./modules/instance"

  instance_name = "db"
  machine_type = "f1-micro"
  vm_zone = "asia-northeast3-c"
  network_tags = ["db", "test"]
  machine_image = "ubuntu-1804-bionic-v20200317"
  subnetwork = module.private_subnet2.sub_network_name
  metadata_Name_value = "private_vm"
}*/


module "instance-templates" {
  source = "./modules/instance-templates"

  name                 = "saas-instance-template"
  instance_description = "Final Project"
  project              = var.project

  tags = ["http-server", "allow-saas-instance"]

  network    = module.network.self_link
  subnetwork = module.private_subnet.self_link
 

  
  metadata_startup_script = "scripts/asia-northeast3-saas-instance.sh"

  labels = {
    environment = terraform.workspace
    purpose     = "Final Project"
  }
}


module "instance-groups" {
  source = "./modules/instance-groups"

  name                      = "saas-instance-group"
  base_instance_name        = "saas"
  region                    = "asia-northeast3"
  distribution_policy_zones = ["asia-northeast3-a", "asia-northeast3-b"]
  instance_template         = module.instance-templates.self_link

  resource_depends_on = [
    module.router-nat
  ]
}



module "load-balancer-external" {
  source = "./modules/load-balancer"

  name            = "vm-test-341412"
  default_service = module.load-balancer-backend.self_link
}

module "load-balancer-target-http-proxy" {
  source = "./modules/load-balancer-target-http-proxy"

  name    = var.project
  url_map = module.load-balancer-external.self_link
}

module "load-balancer-frontend" {
  source = "./modules/load-balancer-frontend"

  name   = var.project
  target = module.load-balancer-target-http-proxy.self_link
}

module "load-balancer-backend" {
  source = "./modules/load-balancer-backend"

  name = var.project
  backends = [
    module.instance-groups.instance_group
  ]
  health_checks = [module.load-balancer-health-check.self_link]
}

module "load-balancer-health-check" {
  source = "./modules/health-check"

  name = "hc-asia-northeast3"
}


module "router" {
  source = "./modules/router"

  name    = format("router-%s", module.private_subnet.region)
  region  = module.private_subnet.region
  network = module.network.self_link
}

module "router-nat" {
  source = "./modules/router-nat"

  name   = format("router-nat-%s", module.private_subnet.region)
  router = module.router.name
  region = module.router.region
}


module "cloudsql-rr" {
  source = "./modules/db"

  general = {
    name       = "db-ha-test9"
    env        = "dev"
    region     = "asia-northeast3"
    db_version = "MYSQL_5_7"
  }

  master = {
    zone = "a"
  }

  replica = {
    zone = "b"
  }
}


/*module "vpn" {
  source = "./modules/vpn"

  classic_vpn_ext_gateway_ip = var.classic_vpn_ext_gateway_ip
  //billing_account_id = var.billing_account_id
  //classic_vpn_folder_id = var.classic_vpn_folder_id
  classic_vpn_shared_secret = var.classic_vpn_shared_secret
  classic_vpn_router_interface_ip_range = var.classic_vpn_router_interface_ip_range
  classic_vpn_router_peer_ip_address = var.classic_vpn_router_peer_ip_address
  //prefix = var.prefix

}*/