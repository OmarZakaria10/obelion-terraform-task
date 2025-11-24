resource "digitalocean_database_cluster" "mysql" {
  name       = "obelion-db"
  engine     = "mysql"
  version    = "8"
  size       = "db-s-1vcpu-1gb"
  region     = var.region
  node_count = 1

  # Private networking only (secure!)
  private_network_uuid = digitalocean_vpc.main.id

  # Tags
  tags = ["obelion", "database"]

  # Maintenance window (Sunday 2 AM UTC)
  maintenance_window {
    day  = "sunday"
    hour = "02:00:00"
  }
}

# Create application database
resource "digitalocean_database_db" "app_db" {
  cluster_id = digitalocean_database_cluster.mysql.id
  name       = "obelion_db"
}

# Database firewall - allow from our servers only
resource "digitalocean_database_firewall" "mysql_fw" {
  cluster_id = digitalocean_database_cluster.mysql.id

  # Allow from droplets with "obelion" tag
  rule {
    type  = "tag"
    value = "obelion"
  }
}