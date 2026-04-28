#!/bin/bash
set -e

echo "=========================================="
echo "Full Infrastructure + App Deployment"
echo "=========================================="
echo ""

# Check if we're in the project root directory
if [ ! -f "main.tf" ]; then
    echo "Error: Please run this script from the project root directory"
    exit 1
fi

# Check if required tools are installed
echo "Checking prerequisites..."

if ! command -v terraform &> /dev/null; then
    echo "Error: Terraform is not installed"
    echo "Install from: https://www.terraform.io/downloads"
    exit 1
fi

if ! command -v ansible &> /dev/null; then
    echo "Error: Ansible is not installed"
    echo "Install it with: pip install ansible"
    exit 1
fi

echo "✓ All prerequisites installed"
echo ""

# Check if build_number is set
if [ -z "$TF_VAR_build_number" ]; then
    echo "Warning: TF_VAR_build_number is not set"
    echo "Setting default value: 1"
    export TF_VAR_build_number="1"
fi

echo "Build number: $TF_VAR_build_number"
echo ""

# Step 1: Initialize Terraform
echo "=========================================="
echo "Step 1: Initializing Terraform"
echo "=========================================="
echo ""

terraform init

echo ""

# Step 2: Apply Terraform
echo "=========================================="
echo "Step 2: Deploying AWS Infrastructure"
echo "=========================================="
echo ""
echo "This will create:"
echo "  - 5 t3.small EC2 instances"
echo "  - Security group (HTTP port 80)"
echo "  - IAM roles and instance profiles"
echo "  - SSH key pair (saved to ~/.ssh/ansible-demo-key.pem)"
echo ""

terraform apply -auto-approve

echo ""
echo "✓ Infrastructure deployed successfully"
echo ""

# Verify SSH key was created
if [ -f ~/.ssh/ansible-demo-key.pem ]; then
    echo "✓ SSH key created at ~/.ssh/ansible-demo-key.pem"
else
    echo "⚠ Warning: SSH key not found at ~/.ssh/ansible-demo-key.pem"
    echo "This may cause connection issues with Ansible"
fi
echo ""

# Step 3: Wait for instances to be ready
echo "=========================================="
echo "Step 3: Waiting for EC2 instances to boot"
echo "=========================================="
echo ""

echo "Waiting 30 seconds for instances to initialize..."
sleep 30

echo "✓ Instances should be ready"
echo ""

# Step 4: Generate Ansible inventory
echo "=========================================="
echo "Step 4: Generating Ansible inventory"
echo "=========================================="
echo ""

terraform output -raw ansible_inventory > ansible/inventory.ini 2>/dev/null || {
    echo "Error: Could not get Terraform output"
    echo "This shouldn't happen if terraform apply succeeded"
    exit 1
}

# Check if inventory has hosts
if ! grep -q "^[0-9]" ansible/inventory.ini; then
    echo "Error: No hosts found in inventory"
    exit 1
fi

echo "✓ Inventory generated successfully"
echo ""

# Display instance information
echo "Instance Public IPs:"
terraform output instance_public_ips
echo ""

# Step 5: Test SSH connectivity
echo "=========================================="
echo "Step 5: Testing SSH connectivity"
echo "=========================================="
echo ""

cd ansible

# Give it a few tries in case instances are still booting
max_attempts=3
attempt=1

while [ $attempt -le $max_attempts ]; do
    echo "Attempt $attempt of $max_attempts..."

    if ansible web_servers -m ping -o; then
        echo "✓ All instances are reachable"
        break
    else
        if [ $attempt -lt $max_attempts ]; then
            echo "⚠ Some instances not ready yet. Waiting 20 seconds..."
            sleep 20
        else
            echo "⚠ Warning: Some instances may not be reachable"
            echo "You may need to wait a moment longer for instances to fully boot"
            read -p "Continue anyway? (y/n) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi
    fi

    attempt=$((attempt + 1))
done

echo ""

# Step 6: Deploy application with Ansible
echo "=========================================="
echo "Step 6: Deploying React Application"
echo "=========================================="
echo ""
echo "This may take 5-10 minutes..."
echo "Tasks: Install Node.js, Nginx, build React app, configure web server"
echo ""

ansible-playbook deploy-react-app.yml

cd ..

echo ""
echo "=========================================="
echo "🎉 Deployment Complete!"
echo "=========================================="
echo ""
echo "Your React application is now running on all 5 instances!"
echo ""
echo "Access your application at:"
terraform output website_urls
echo ""
echo "SSH Private Key: ~/.ssh/ansible-demo-key.pem"
echo ""
echo "Useful commands:"
echo "  - Check app status: cd ansible && ansible web_servers -m shell -a 'systemctl status nginx' --become"
echo "  - View logs: cd ansible && ansible web_servers -m shell -a 'tail -50 /var/log/nginx/error.log' --become"
echo "  - Redeploy app only: ./deploy.sh"
echo "  - Destroy infrastructure: terraform destroy"
echo ""
