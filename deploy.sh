#!/bin/bash
set -e

echo "=========================================="
echo "React App Ansible Deployment Script"
echo "=========================================="
echo ""

# Check if we're in the project root directory
if [ ! -f "main.tf" ]; then
    echo "Error: Please run this script from the project root directory"
    exit 1
fi

# Check if Ansible is installed
if ! command -v ansible &> /dev/null; then
    echo "Error: Ansible is not installed"
    echo "Install it with: pip install ansible"
    exit 1
fi

# Generate inventory from Terraform
echo "Step 1: Generating Ansible inventory from Terraform output..."

terraform output -raw ansible_inventory > ansible/inventory.ini 2>/dev/null || {
    echo "Error: Could not get Terraform output"
    echo "Make sure you have run 'terraform apply' first"
    exit 1
}

# Check if inventory has hosts
if ! grep -q "^[0-9]" ansible/inventory.ini; then
    echo "Error: No hosts found in inventory"
    echo "Please ensure EC2 instances are created with 'terraform apply'"
    exit 1
fi

echo "✓ Inventory generated successfully"
echo ""

# Test connectivity
echo "Step 2: Testing SSH connectivity to instances..."
cd ansible
if ansible web_servers -m ping -o; then
    echo "✓ All instances are reachable"
else
    echo "⚠ Warning: Some instances may not be reachable"
    echo "You may need to wait a moment for instances to fully boot"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi
echo ""

# Run deployment
echo "Step 3: Deploying React application..."
echo "This may take several minutes..."
echo ""

ansible-playbook deploy-react-app.yml

echo ""
echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo ""
echo "Access your application at:"
cd ..
terraform output website_urls
