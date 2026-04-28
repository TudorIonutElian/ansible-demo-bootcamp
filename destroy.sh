#!/bin/bash
set -e

echo "=========================================="
echo "Infrastructure Destruction Script"
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

echo "✓ Terraform installed"
echo ""

# Safety confirmation
echo "⚠️  WARNING: This will DESTROY all infrastructure! ⚠️"
echo ""
echo "This will permanently delete:"
echo "  - All EC2 instances (5x t3.small)"
echo "  - Security groups"
echo "  - IAM roles and instance profiles"
echo "  - SSH key pair from AWS"
echo ""
echo "Note: Local SSH key at ~/.ssh/ansible-demo-key.pem will NOT be deleted"
echo ""

read -p "Are you sure you want to destroy all infrastructure? Type 'yes' to confirm: " confirmation

if [ "$confirmation" != "yes" ]; then
    echo ""
    echo "❌ Destruction cancelled"
    exit 0
fi

echo ""

# Initialize Terraform (in case state is out of sync)
echo "=========================================="
echo "Step 1: Initializing Terraform"
echo "=========================================="
echo ""

terraform init

echo ""

# Show what will be destroyed
echo "=========================================="
echo "Step 2: Planning destruction"
echo "=========================================="
echo ""
echo "📋 The following resources will be DESTROYED:"
echo ""

terraform plan -destroy

echo ""
read -p "Proceed with destruction? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Destruction cancelled"
    exit 0
fi

echo ""

# Destroy infrastructure
echo "=========================================="
echo "Step 3: Destroying infrastructure"
echo "=========================================="
echo ""

terraform destroy

echo ""

# Cleanup local files (optional)
echo "=========================================="
echo "Step 4: Cleanup local files"
echo "=========================================="
echo ""

if [ -f "ansible/inventory.ini" ]; then
    echo "Removing ansible/inventory.ini"
    rm -f ansible/inventory.ini
fi

echo ""
echo "=========================================="
echo "✅ Destruction Complete!"
echo "=========================================="
echo ""
echo "All AWS resources have been destroyed."
echo ""
echo "Local files preserved:"
echo "  - SSH key: ~/.ssh/ansible-demo-key.pem (delete manually if not needed)"
echo "  - Terraform state: terraform.tfstate"
echo ""
echo "To completely clean up:"
echo "  - Delete SSH key: rm ~/.ssh/ansible-demo-key.pem"
echo "  - Delete Terraform state: rm terraform.tfstate*"
echo ""
