# ============================================================================
# VARIABLES - All configurable options
# ============================================================================

# DigitalOcean API Token
variable "do_token" {
  description = "DigitalOcean API token (or use DIGITALOCEAN_TOKEN environment variable)"
  type        = string
  default     = ""
  sensitive   = true
}

# SSH Key Name
variable "ssh_key_name" {
  description = "Name of your SSH key in DigitalOcean (upload it first!)"
  type        = string
  default     = "obelion-key"
}

# Region
variable "region" {
  description = "DigitalOcean region to deploy in"
  type        = string
  default     = "nyc3"

  validation {
    condition = contains([
      "nyc1", "nyc3", "sfo3", "sgp1", "lon1",
      "fra1", "tor1", "blr1", "ams3", "syd1"
    ], var.region)
    error_message = "Region must be a valid DigitalOcean region"
  }
}

# Alert Email
variable "alert_email" {
  description = "Your email address for monitoring alerts"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.alert_email))
    error_message = "Must be a valid email address"
  }
}

# CPU Alert Threshold
variable "cpu_alert_threshold" {
  description = "CPU percentage to trigger alert (default: 50%)"
  type        = number
  default     = 50

  validation {
    condition     = var.cpu_alert_threshold >= 10 && var.cpu_alert_threshold <= 100
    error_message = "CPU threshold must be between 10 and 100"
  }
}
