# Obelion Task - DigitalOcean Infrastructure (Simple Version)

This is a **simplified** Terraform configuration for the Obelion internship assessment. Everything is in one place - easy to understand and deploy!

## What This Creates

- ✅ **2 Virtual Machines (Droplets)**:
  - Backend server for Laravel app (1GB RAM, 1 CPU)
  - Frontend server for Uptime Kuma (1GB RAM, 1 CPU)
- ✅ **MySQL Database**: Managed database (private, secure)
- ✅ **Private Network**: VPC so servers can talk securely
- ✅ **Firewall**: Security rules for web traffic
- ✅ **Monitoring**: Email alerts when CPU > 50%

**Total Cost**: ~$27/month (covered by free credit!)

## Prerequisites (Things You Need First)

### 1. DigitalOcean Account

- Sign up at https://www.digitalocean.com/
- New accounts get **$200 free credit**! 🎉

### 2. Get Your API Token

```bash
# Step 1: Go to: https://cloud.digitalocean.com/account/api/tokens
# Step 2: Click "Generate New Token"
# Step 3: Name it "terraform-token" and check both Read & Write
# Step 4: Copy the token and run this:
export DIGITALOCEAN_TOKEN="dop_v1_your_token_here"
```

### 3. Upload SSH Key

```bash
# If you don't have an SSH key, create one:
ssh-keygen -t ed25519 -C "your_email@example.com"

# Upload to DigitalOcean:
# 1. Go to: https://cloud.digitalocean.com/account/security
# 2. Click "Add SSH Key"
# 3. Paste content from: cat ~/.ssh/id_ed25519.pub
# 4. Name it: "obelion-key"
```

### 4. Install Terraform

```bash
# Ubuntu/Debian:
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Verify:
terraform version
```

## Quick Start Guide 🚀

### Step 1: Clone and Setup

```bash
cd terraform-Obelion-task-simple

# Copy example config
cp terraform.tfvars.example terraform.tfvars

# Edit with your details
nano terraform.tfvars
```

### Step 2: Configure Variables

Edit `terraform.tfvars`:

```hcl
# Your DigitalOcean API token (or use environment variable)
do_token = ""  # Leave empty if using DIGITALOCEAN_TOKEN env var

# Your email for alerts
alert_email = "your-email@example.com"

# Your SSH key name (as it appears in DigitalOcean)
ssh_key_name = "obelion-key"

# Region (choose closest to you)
region = "nyc3"  # Options: nyc1, nyc3, sfo3, lon1, fra1, sgp1
```

### Step 3: Deploy!

```bash
# Initialize Terraform (downloads DigitalOcean provider)
terraform init

# See what will be created (won't create anything yet)
terraform plan

# Create everything! (will ask for confirmation)
terraform apply

# Type "yes" when prompted
```

⏱️ **Wait 5-10 minutes** for everything to be created.

### Step 4: Get Your Server IPs

```bash
# Show all outputs
terraform output

# Get specific IP
terraform output backend_public_ip
terraform output frontend_public_ip
```

## What You'll Get

After deployment, you'll see:

```
Apply complete! Resources: 9 added, 0 changed, 0 destroyed.

Outputs:

backend_public_ip = "164.92.xxx.xxx"
frontend_public_ip = "164.92.xxx.xxx"
database_host = "private-db-mysql-nyc3-xxxxx.db.ondigitalocean.com"
database_name = "obelion_db"
database_port = 25060
database_user = "doadmin"

connection_info = {
  "backend_ssh" = "ssh root@164.92.xxx.xxx"
  "frontend_ssh" = "ssh root@164.92.xxx.xxx"
}
```

## Connecting to Your Servers

### Backend Server (Laravel)

```bash
# SSH into backend
ssh root@$(terraform output -raw backend_public_ip)

# Check if everything installed
php --version
composer --version
nginx -v
```

### Frontend Server (Uptime Kuma)

```bash
# SSH into frontend
ssh root@$(terraform output -raw frontend_public_ip)

# Check Docker
docker --version
docker-compose --version
```

### Database Connection

```bash
# From backend server, connect to database:
mysql -h $(terraform output -raw database_host) \
      -P $(terraform output -raw database_port) \
      -u $(terraform output -raw database_user) \
      -p \
      $(terraform output -raw database_name)

# Password will be prompted (get it from: terraform output database_password)
```

## File Structure

```
terraform-Obelion-task-simple/
├── main.tf                    # 👈 All infrastructure defined here
├── variables.tf               # 👈 All variables (inputs)
├── outputs.tf                 # 👈 What you get after deployment
├── terraform.tfvars.example   # 👈 Example configuration
├── terraform.tfvars           # 👈 Your actual config (DO NOT COMMIT!)
├── user-data-backend.sh       # Backend server setup script
├── user-data-frontend.sh      # Frontend server setup script
├── .gitignore                 # Files to ignore in git
└── README.md                  # This file!
```

## Understanding the Files

### main.tf
Contains all infrastructure resources:
- VPC (private network)
- 2 Droplets (servers)
- MySQL database
- Firewall rules
- Monitoring alerts

### variables.tf
Defines all the inputs you can customize:
- Region, server sizes, database config, etc.

### outputs.tf
Shows important info after deployment:
- Server IPs, database credentials, connection strings

### user-data-*.sh
Scripts that run automatically when servers start:
- Install software, configure services

## Common Tasks

### Check Status

```bash
# See current infrastructure
terraform show

# List all resources
terraform state list
```

### Update Infrastructure

```bash
# Made changes to main.tf? Apply them:
terraform plan   # Preview changes
terraform apply  # Apply changes
```

### View Sensitive Data

```bash
# Database password
terraform output database_password

# Full connection string
terraform output database_connection_string
```

### Destroy Everything

```bash
# ⚠️ WARNING: This deletes everything!
terraform destroy

# Type "yes" to confirm
```

## Troubleshooting

### Error: "API token not found"

```bash
# Make sure token is set:
echo $DIGITALOCEAN_TOKEN

# If empty, set it:
export DIGITALOCEAN_TOKEN="dop_v1_xxxxx"
```

### Error: "SSH key not found"

```bash
# Check SSH key name in DigitalOcean matches terraform.tfvars
# Go to: https://cloud.digitalocean.com/account/security
# Update ssh_key_name in terraform.tfvars
```

### Can't SSH to servers

```bash
# Wait 2-3 minutes after deployment for cloud-init to finish
# Check if using correct SSH key:
ssh -i ~/.ssh/id_ed25519 root@<server_ip>
```

### Database connection fails

```bash
# Database is PRIVATE - only accessible from backend server
# Connect FROM backend server, not your local machine
ssh root@<backend_ip>
# Then from inside: mysql -h <db_host> -u <db_user> -p
```

## Next Steps

After deployment:

1. **Deploy Laravel**: SSH to backend, clone repo, configure `.env`
2. **Deploy Uptime Kuma**: SSH to frontend, run docker-compose
3. **Setup CI/CD**: Configure GitHub Actions for auto-deployment
4. **Test Monitoring**: Stress test CPU to verify alerts work

## Cost Breakdown

| Resource | Cost/Month |
|----------|-----------|
| Backend Droplet (1GB) | $6 |
| Frontend Droplet (1GB) | $6 |
| MySQL Database (1GB) | $15 |
| **Total** | **$27** |

With $200 credit = **~7 months free!**

## Security Notes

- ⚠️ Never commit `terraform.tfvars` (contains secrets)
- ⚠️ Never commit `.tfstate` files (contain sensitive data)
- ✅ Database is private (only accessible within VPC)
- ✅ Firewall rules restrict access
- ✅ SSH key authentication only (no passwords)

## Resources

- [DigitalOcean Docs](https://docs.digitalocean.com/)
- [Terraform Docs](https://www.terraform.io/docs)
- [Terraform DigitalOcean Provider](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs)

## Need Help?

1. Check the [troubleshooting section](#troubleshooting)
2. Review Terraform error messages (they're usually helpful!)
3. Check DigitalOcean console: https://cloud.digitalocean.com/
4. Ask your mentor or team lead

---

**Good luck with your internship assessment! 🚀**
