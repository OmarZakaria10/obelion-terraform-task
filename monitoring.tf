# Alert for backend CPU usage
resource "digitalocean_monitor_alert" "backend_cpu" {
  alerts {
    email = [var.alert_email]
  }

  window      = "5m"
  type        = "v1/insights/droplet/cpu"
  compare     = "GreaterThan"
  value       = var.cpu_alert_threshold
  enabled     = true
  entities    = [digitalocean_droplet.backend.id]
  description = "Backend CPU exceeds ${var.cpu_alert_threshold}%"

  tags = ["obelion", "backend", "cpu-alert"]
}

# Alert for frontend CPU usage
resource "digitalocean_monitor_alert" "frontend_cpu" {
  alerts {
    email = [var.alert_email]
  }

  window      = "5m"
  type        = "v1/insights/droplet/cpu"
  compare     = "GreaterThan"
  value       = var.cpu_alert_threshold
  enabled     = true
  entities    = [digitalocean_droplet.frontend.id]
  description = "Frontend CPU exceeds ${var.cpu_alert_threshold}%"

  tags = ["obelion", "frontend", "cpu-alert"]
}