# ============================================================================
# OUTPUTS - Information you'll need after deployment
# ============================================================================

# Backend Server
output "backend_droplet_id" {
  description = "Backend server ID"
  value       = digitalocean_droplet.backend.id
}

output "backend_public_ip" {
  description = "Backend server public IP (use this to SSH)"
  value       = digitalocean_droplet.backend.ipv4_address
}

output "backend_private_ip" {
  description = "Backend server private IP (for internal communication)"
  value       = digitalocean_droplet.backend.ipv4_address_private
}

# Frontend Server
output "frontend_droplet_id" {
  description = "Frontend server ID"
  value       = digitalocean_droplet.frontend.id
}

output "frontend_public_ip" {
  description = "Frontend server public IP (use this to SSH)"
  value       = digitalocean_droplet.frontend.ipv4_address
}

output "frontend_private_ip" {
  description = "Frontend server private IP (for internal communication)"
  value       = digitalocean_droplet.frontend.ipv4_address_private
}

# Database
output "database_id" {
  description = "Database cluster ID"
  value       = digitalocean_database_cluster.mysql.id
}

output "database_host" {
  description = "Database host (PRIVATE - only accessible from VPC)"
  value       = digitalocean_database_cluster.mysql.private_host
}

output "database_port" {
  description = "Database port"
  value       = digitalocean_database_cluster.mysql.port
}

output "database_name" {
  description = "Database name"
  value       = digitalocean_database_db.app_db.name
}

output "database_user" {
  description = "Database username"
  value       = digitalocean_database_cluster.mysql.user
}

output "database_password" {
  description = "Database password (sensitive - use: terraform output database_password)"
  value       = digitalocean_database_cluster.mysql.password
  sensitive   = true
}

# Connection Strings
output "database_connection_string" {
  description = "MySQL connection string (use from backend server only!)"
  value       = "mysql://${digitalocean_database_cluster.mysql.user}:${digitalocean_database_cluster.mysql.password}@${digitalocean_database_cluster.mysql.private_host}:${digitalocean_database_cluster.mysql.port}/${digitalocean_database_db.app_db.name}"
  sensitive   = true
}

output "connection_info" {
  description = "Quick reference for SSH connections"
  value = {
    backend_ssh  = "ssh root@${digitalocean_droplet.backend.ipv4_address}"
    frontend_ssh = "ssh root@${digitalocean_droplet.frontend.ipv4_address}"
    database_uri = "Connect from backend server using private host"
  }
}

# VPC
output "vpc_id" {
  description = "VPC ID"
  value       = digitalocean_vpc.main.id
}

# Quick Start Guide
output "next_steps" {
  description = "What to do next"
  value       = <<-EOT
  
  ✅ Infrastructure deployed successfully!
  
  Next steps:
  
  1. SSH to backend:  ${digitalocean_droplet.backend.ipv4_address}
  2. SSH to frontend: ${digitalocean_droplet.frontend.ipv4_address}
  3. Get DB password: terraform output database_password
  4. Test DB connection from backend server
  5. Deploy your Laravel application
  6. Deploy Uptime Kuma with Docker
  
  Check the README.md for detailed instructions!
  EOT
}
