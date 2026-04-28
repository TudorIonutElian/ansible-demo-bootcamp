#!/bin/bash
set -e

echo "=========================================="
echo "Terraform Backend Setup"
echo "=========================================="
echo ""

# Configuration
BUCKET_NAME="aws-ansible-demo-terraform-state-2026"
REGION="eu-central-1"

echo "Creating S3 bucket for Terraform state..."
echo "Bucket name: $BUCKET_NAME"
echo "Region: $REGION"
echo ""

# Create S3 bucket
aws s3api create-bucket \
  --bucket "$BUCKET_NAME" \
  --region "$REGION" \
  --create-bucket-configuration LocationConstraint="$REGION" \
  2>/dev/null || echo "Bucket already exists"

# Enable versioning
echo "Enabling versioning..."
aws s3api put-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --versioning-configuration Status=Enabled

# Enable encryption
echo "Enabling encryption..."
aws s3api put-bucket-encryption \
  --bucket "$BUCKET_NAME" \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Block public access
echo "Blocking public access..."
aws s3api put-public-access-block \
  --bucket "$BUCKET_NAME" \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

echo ""
echo "=========================================="
echo "✅ Backend Setup Complete!"
echo "=========================================="
echo ""
echo "Bucket configured in main.tf:"
echo "  bucket = \"$BUCKET_NAME\""
echo ""
echo "Next steps:"
echo "  1. Run: terraform init -migrate-state"
echo "  2. Commit the updated main.tf"
echo ""
