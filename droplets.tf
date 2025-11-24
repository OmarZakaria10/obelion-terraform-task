
# Backend Droplet (for Laravel application)
resource "digitalocean_droplet" "backend" {
  name   = "obelion-backend"
  region = var.region
  size   = "s-1vcpu-1gb"
  image  = "ubuntu-22-04-x64"

  # Use our SSH key
  ssh_keys = [data.digitalocean_ssh_key.main.id]

  # Connect to VPC
  vpc_uuid = digitalocean_vpc.main.id

  # Install required software automatically
  user_data = file("${path.module}/user-data-backend.sh")

  # Enable monitoring
  monitoring = true

  # Tags for firewall and organization
  tags = ["obelion", "backend", "laravel"]
}

# Frontend Droplet (for Uptime Kuma)
resource "digitalocean_droplet" "frontend" {
  name   = "obelion-frontend"
  region = var.region
  size   = "s-1vcpu-1gb"
  image  = "ubuntu-22-04-x64"

  # Use our SSH key
  ssh_keys = [data.digitalocean_ssh_key.main.id]

  # Connect to VPC
  vpc_uuid = digitalocean_vpc.main.id

  # Install Docker automatically
  user_data = file("${path.module}/user-data-frontend.sh")

  # Enable monitoring
  monitoring = true

  # Tags for firewall and organization
  tags = ["obelion", "frontend", "uptime-kuma"]
}

# Create firewall rules
resource "digitalocean_firewall" "web" {
  name = "obelion-firewall"

  # Apply to all our servers
  tags = ["obelion"]

  # Allow SSH (port 22)
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Allow HTTP (port 80)
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Allow HTTPS (port 443)
  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Allow ping
  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Allow all outbound traffic (for package installation, updates, etc.)
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
