# VPC (private network for secure communication)
resource "digitalocean_vpc" "main" {
  name     = "obelion-vpc"
  region   = var.region
  ip_range = "10.0.0.0/16"
}
