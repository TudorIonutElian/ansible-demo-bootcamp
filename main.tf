/**********************************************************
  # Configure the AWS Provider
  # source: https://registry.terraform.io/providers/hashicorp/
  # version: ~> 5.0
**********************************************************/

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


/**********************************************************
  # Add configuration to authorisation keys
  # Configure the AWS Provider
**********************************************************/

provider "aws" {
  region = "eu-central-1"

  # Only use profile-based auth when AWS_ACCESS_KEY_ID is not set (local dev)
  # In GitHub Actions, credentials come from environment variables via
  # aws-actions/configure-aws-credentials action
}
