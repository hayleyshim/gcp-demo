resource "google_compute_firewall" "this" {
  name    = var.firewall_rule_name
  network = var.network


  allow {
    protocol = var.protocol_type
    ports    = var.ports_types
  }

  source_tags = var.source_tags
  source_ranges = var.source_ranges
  target_tags = var.target_tags
}
