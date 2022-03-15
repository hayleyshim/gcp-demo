resource "google_compute_backend_service" "this" {
  // count                 = var.load_balancing_scheme == "EXTERNAL" ? 1 : 0

  name                  = var.name
  health_checks         = var.health_checks
  load_balancing_scheme = "EXTERNAL"
  port_name             = "http"
  protocol              = "HTTP"
  timeout_sec           = 10
  session_affinity      = "NONE"

  dynamic "backend" {
    for_each = var.backends
    content {
      group  = backend.value
      balancing_mode        = var.balancing_mode
      max_rate_per_instance = 1
    }
  }
}