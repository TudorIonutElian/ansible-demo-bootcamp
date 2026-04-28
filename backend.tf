terraform {
    backend "s3" {
        bucket         = "aws-ansible-demo-terraform-state-2026"
        key            = "aws-systems-manager-demo/terraform.tfstate"
        region         = "eu-central-1"
        encrypt        = true
    }
}