terraform {
  required_version = ">= 1.6.0"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Configure DigitalOcean provider
provider "digitalocean" {
  token = var.do_token != "" ? var.do_token : null
}

# Get SSH key from DigitalOcean account
data "digitalocean_ssh_key" "main" {
  name = var.ssh_key_name
}
