resource "google_compute_subnetwork" "subnetwork" {
  name          = var.subnetwork_name
  ip_cidr_range = var.cidr
  region        = var.subnetwork_region
  network       = var.network
  depends_on = [var.depends_on_resoures]
  private_ip_google_access = var.private_ip_google_access

}
