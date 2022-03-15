resource "google_compute_instance" "virtual-machine" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.vm_zone

  tags = var.network_tags

  boot_disk {
    initialize_params {
      image = var.machine_image
    }
  }

  network_interface {
    subnetwork = var.subnetwork

   /* access_config {
      // Ephemeral IP - 공인 IP 제거
    }*/
  }

  metadata = {
    Name = var.metadata_Name_value
    //enable-oslogin = "TRUE"

  }
}  