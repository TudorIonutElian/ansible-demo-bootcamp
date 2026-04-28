# AWS EC2 + Ansible React App Deployment

Complete infrastructure-as-code solution that deploys a React web application to 5 AWS EC2 instances using Terraform for infrastructure and Ansible for application deployment.

## 🚀 Quick Start

**One-command deployment:**

```bash
./full-deploy.sh
```

That's it! In ~10-15 minutes you'll have:
- ✅ 5 EC2 instances running in AWS
- ✅ React app deployed and running
- ✅ Nginx web server configured
- ✅ All accessible via HTTP

## 📋 Table of Contents

- [What This Project Does](#what-this-project-does)
- [Prerequisites](#prerequisites)
- [Deployment Options](#deployment-options)
- [How It Works](#how-it-works)
- [Project Structure](#project-structure)
- [Common Operations](#common-operations)
- [Troubleshooting](#troubleshooting)
- [Documentation](#documentation)

## What This Project Does

This project automates the complete deployment of a React application across multiple EC2 instances:

### Infrastructure (Terraform)
- Provisions 5 t3.small EC2 instances (Amazon Linux 2023)
- Creates security groups allowing HTTP (port 80) and SSH (port 22) traffic
- Sets up IAM roles for AWS and Ansible access
- Generates SSH key pair for secure access
- Configures networking and security

### Application (Ansible)
- Installs Node.js 18 and npm
- Installs and configures Nginx web server
- Copies and builds React application
- Configures production-ready Nginx settings:
  - SPA routing support (React Router)
  - Gzip compression
  - Static asset caching
  - Security headers

## Prerequisites

### Required Tools

- **AWS Account** with permissions for EC2, IAM, SSM, and VPC
- **Terraform** (v1.0+) - [Install](https://www.terraform.io/downloads)
- **Ansible** (v2.14+) - Install: `pip install ansible`
- **AWS CLI** configured with credentials
- **Python 3** installed locally

### AWS Setup

1. Configure AWS credentials:
   ```bash
   aws configure
   ```

2. Ensure you have an S3 bucket and DynamoDB table for Terraform state (see [backend.tf](backend.tf))

### Install Dependencies

```bash
# Install Ansible
pip install -r ansible/requirements.txt

# Or install directly
pip install ansible
```

## Deployment Options

### Option 1: Full Deployment (Recommended for First Time)

Deploy everything with one command:

```bash
./full-deploy.sh
```

**What it does:**
1. Initializes Terraform
2. Creates AWS infrastructure (EC2, security groups, IAM, SSH keys)
3. Waits for instances to boot
4. Generates Ansible inventory
5. Tests SSH connectivity (with retries)
6. Deploys React application
7. Shows application URLs

**Time:** ~10-15 minutes

### Option 2: Application-Only Deployment

If infrastructure already exists, deploy just the app:

```bash
./deploy.sh
```

**What it does:**
1. Generates Ansible inventory from Terraform
2. Tests SSH connectivity
3. Deploys React application
4. Shows application URLs

**Time:** ~5-8 minutes  
**Requires:** Infrastructure already created

### Option 3: Manual Step-by-Step

For complete control:

```bash
# 1. Deploy infrastructure
export TF_VAR_build_number="1"
terraform init
terraform apply

# 2. Generate inventory
terraform output -raw ansible_inventory > ansible/inventory.ini

# 3. Deploy application
cd ansible
ansible-playbook deploy-react-app.yml

# 4. Get URLs
cd ..
terraform output website_urls
```

## How It Works

### 🔑 SSH Authentication

When you run `terraform apply` or `./full-deploy.sh`, Terraform automatically:

1. **Generates RSA key pair** (2048-bit)
2. **Saves private key** to `~/.ssh/ssm-key.pem` (permissions: 600)
3. **Registers public key** with AWS
4. **Attaches key to all instances**

Ansible then uses this key to connect via SSH:

```ini
[web_servers]
<instance-ip> ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/ssm-key.pem
```

**Connection Details:**
- **User:** `ec2-user` (default for Amazon Linux 2023)
- **Key:** `~/.ssh/ssm-key.pem`
- **Method:** SSH with key-based authentication

### 📦 Deployment Flow

```
┌─────────────────────────────────────┐
│  1. Terraform Creates Infrastructure │
│     - 5 EC2 instances               │
│     - Security groups               │
│     - SSH key pair                  │
│     - IAM roles                     │
└─────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────┐
│  2. Ansible Deploys Application     │
│     - Install Node.js & Nginx       │
│     - Copy React app                │
│     - Build production bundle       │
│     - Configure Nginx               │
│     - Start services                │
└─────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────┐
│  3. Access Application              │
│     http://<instance-ip>            │
└─────────────────────────────────────┘
```

## Project Structure

```
.
├── full-deploy.sh          # 🚀 Complete deployment (Terraform + Ansible)
├── deploy.sh               # 📦 Application-only deployment
├── main.tf                 # AWS provider configuration
├── backend.tf              # S3 remote state backend
├── variables.tf            # Input variables
├── outputs.tf              # Terraform outputs (IPs, inventory)
├── ec2.tf                  # 5 t3.small EC2 instances
├── security-group.tf       # HTTP security group
├── iam.tf                  # IAM roles and policies
├── key-pair.tf             # SSH key generation
├── ami-filter.tf           # Amazon Linux 2023 AMI
├── ansible/                # Ansible deployment
│   ├── ansible.cfg         # Ansible configuration
│   ├── deploy-react-app.yml # Main playbook
│   ├── inventory.ini.template
│   ├── requirements.txt
│   └── roles/webserver/
│       ├── tasks/
│       ├── handlers/
│       └── templates/
├── web/                    # React application
│   ├── src/
│   ├── package.json
│   └── vite.config.js
└── documents/              # SSM documents (optional)
```

## Common Operations

### Access Your Application

```bash
# Get all application URLs
terraform output website_urls
```

Visit any URL in your browser!

### Re-deploy Application

After updating React app code:

```bash
./deploy.sh
```

### Check Application Status

```bash
cd ansible
ansible web_servers -m shell -a "systemctl status nginx" --become
```

### View Nginx Logs

```bash
cd ansible
ansible web_servers -m shell -a "tail -50 /var/log/nginx/error.log" --become
```

### Restart Nginx

```bash
cd ansible
ansible web_servers -m systemd -a "name=nginx state=restarted" --become
```

### SSH into an Instance

```bash
# Get instance IPs
terraform output instance_public_ips

# Connect
ssh -i ~/.ssh/ssm-key.pem ec2-user@<instance-ip>
```

### Destroy Infrastructure

```bash
terraform destroy
```

## Troubleshooting

### SSH Permission Denied

**Problem:** Ansible can't connect to instances

**Solutions:**

1. Check key permissions:
   ```bash
   chmod 600 ~/.ssh/ssm-key.pem
   ```

2. Verify key exists:
   ```bash
   ls -la ~/.ssh/ssm-key.pem
   ```

3. Test SSH manually:
   ```bash
   ssh -i ~/.ssh/ssm-key.pem ec2-user@<instance-ip>
   ```

### Connection Timeout

**Problem:** Can't reach instances

**Solutions:**

1. Wait 1-2 minutes after `terraform apply` for instances to fully boot
2. Check security group allows SSH (port 22)
3. Verify instances are running:
   ```bash
   terraform output instance_ids
   ```

### "Terraform output error"

**Problem:** `./deploy.sh` fails to generate inventory

**Solution:** Run `terraform apply` first or use `./full-deploy.sh`

### Application Not Accessible

**Problem:** Can't access app via HTTP

**Solutions:**

1. Check Nginx is running:
   ```bash
   cd ansible
   ansible web_servers -m shell -a "systemctl status nginx" --become
   ```

2. Check security group allows port 80:
   ```bash
   terraform output security_group_id
   ```

3. View Nginx error logs:
   ```bash
   cd ansible
   ansible web_servers -m shell -a "tail -50 /var/log/nginx/error.log" --become
   ```

## Terraform Outputs

| Output | Description |
|--------|-------------|
| `instance_ids` | IDs of all 5 EC2 instances |
| `instance_public_ips` | Public IP addresses |
| `instance_private_ips` | Private IP addresses |
| `website_urls` | Direct URLs to access the app |
| `ansible_inventory` | Pre-formatted Ansible inventory |
| `security_group_id` | Security group ID |
| `ssh_private_key_path` | Path to SSH private key |

## Variables

| Name | Description | Default |
|------|-------------|---------|
| `build_number` | Build/deployment number (required) | - |
| `startsWith` | AMI name prefix filter | `al2023-ami` |
| `endsWith` | AMI name suffix filter | `x86_64` |
| `architecture` | AMI architecture | `x86_64` |

**Note:** Instance count (5) and type (t3.small) are hardcoded in [ec2.tf](ec2.tf).

## Cost Estimate

**EC2 Instances:**
- 5 x t3.small instances
- Approximate: $0.0208/hour per instance
- **Total: ~$0.10/hour or ~$75/month** (if running 24/7)

**Other Resources:**
- Security groups, IAM roles, SSH keys: **Free**
- Data transfer: First 100GB/month **free**

**💡 Tip:** Stop instances when not in use:
```bash
aws ec2 stop-instances --instance-ids $(terraform output -json instance_ids | jq -r '.[]')
```

## Security Considerations

### SSH Key Security

- ✅ Private key stored at `~/.ssh/ssm-key.pem` with 600 permissions
- ✅ Never commit private key to git
- ✅ Key is generated fresh on each `terraform apply`
- ⚠️ Keep backup of private key in secure location

### Network Security

- ⚠️ HTTP (port 80) is open to the world (0.0.0.0/0)
- 💡 For production: Add HTTPS with SSL/TLS certificates
- 💡 Consider restricting SSH access to specific IPs

### Best Practices

1. Rotate SSH keys periodically
2. Use HTTPS in production (Let's Encrypt)
3. Enable CloudWatch monitoring
4. Set up automated backups
5. Implement least-privilege IAM policies

## Documentation

This project includes comprehensive documentation:

| Document | Description |
|----------|-------------|
| **README.md** (this file) | Complete project overview and guide |
| [QUICK_START.md](QUICK_START.md) | Fast deployment guide |
| [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) | Detailed step-by-step instructions |
| [SCRIPTS_GUIDE.md](SCRIPTS_GUIDE.md) | Comparison of deployment scripts |
| [SSH_CONNECTION.md](SSH_CONNECTION.md) | SSH authentication explained |
| [CONNECTION_FLOW.md](CONNECTION_FLOW.md) | Visual connection diagrams |
| [FULL_DEPLOY_FLOW.md](FULL_DEPLOY_FLOW.md) | Complete deployment flow breakdown |
| [ansible/README.md](ansible/README.md) | Ansible-specific documentation |

## Which Script Should I Use?

| Scenario | Command |
|----------|---------|
| **First deployment** | `./full-deploy.sh` |
| **Infrastructure exists, deploy app** | `./deploy.sh` |
| **Updated React code** | `./deploy.sh` |
| **Changed Terraform config** | `terraform apply` then `./deploy.sh` |
| **Start completely fresh** | `terraform destroy` then `./full-deploy.sh` |

## Development Workflow

### Initial Setup
```bash
./full-deploy.sh
```

### Iterate on React App
```bash
# 1. Edit files in web/src/
# 2. Deploy changes
./deploy.sh
```

### Change Infrastructure
```bash
# 1. Edit Terraform files (*.tf)
# 2. Apply changes
terraform apply
# 3. Re-deploy app if needed
./deploy.sh
```

### Modify Ansible Configuration
```bash
# 1. Edit ansible/roles/webserver/
# 2. Re-deploy
./deploy.sh
```

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                  AWS Cloud                          │
│                                                     │
│  ┌──────────────────────────────────────────────┐ │
│  │         5 x t3.small EC2 Instances           │ │
│  │                                              │ │
│  │  Each instance runs:                        │ │
│  │  ├─ Amazon Linux 2023                       │ │
│  │  ├─ Node.js 18                              │ │
│  │  ├─ Nginx                                   │ │
│  │  ��─ React App (/opt/webapp)                 │ │
│  │  └─ Production Build (/opt/webapp/dist)     │ │
│  │                                              │ │
│  └──────────────────────────────────────────────┘ │
│                      ↑                             │
│                      │ Port 80 (HTTP)             │
│  ┌──────────────────────────────────────────────┐ │
│  │         Security Group                       │ │
│  │         Allow: HTTP (80) from 0.0.0.0/0     │ │
│  └──────────────────────────────────────────────┘ │
│                                                     │
│  ┌──────────────────────────────────────────────┐ │
│  │         IAM Role & Instance Profile          │ │
│  │         Permissions: SSM, EC2                │ │
│  └──────────────────────────────────────────────┘ │
│                                                     │
└─────────────────────────────────────────────────────┘
                      ↑
                      │ SSH (port 22)
                      │ ~/.ssh/ssm-key.pem
                      │
            ┌─────────────────────┐
            │   Your Machine      │
            │   - Terraform       │
            │   - Ansible         │
            └─────────────────────┘
```

## Technology Stack

### Infrastructure
- **Terraform** - Infrastructure as Code
- **AWS EC2** - Virtual servers
- **AWS IAM** - Access management
- **AWS S3** - Terraform state storage

### Configuration Management
- **Ansible** - Application deployment and configuration
- **SSH** - Secure remote access

### Application
- **React** - Frontend framework
- **Vite** - Build tool
- **Nginx** - Web server
- **Node.js** - JavaScript runtime

## Contributing

Feel free to submit issues or pull requests for improvements!

## License

This project is open source and available for educational and demonstration purposes.

## Support

For questions or issues:
1. Check the [documentation](#documentation) files
2. Review [troubleshooting](#troubleshooting) section
3. Open an issue on GitHub

## Next Steps

After successful deployment:

1. ✅ Visit the application URLs
2. ✅ Test the React app functionality
3. ✅ Customize the React app in `web/src/`
4. ✅ Re-deploy with `./deploy.sh`
5. ✅ Explore Ansible roles for customization
6. ✅ Add HTTPS for production use
7. ✅ Set up monitoring and alerting

---

**Ready to deploy?** Run `./full-deploy.sh` and you're live in 15 minutes! 🚀
