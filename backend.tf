terraform {
    backend "s3" {
        bucket         = "aws-ansible-demo-terraform-state-2026"
        key            = "aws-ansible-demo/terraform.tfstate"
        region         = "eu-central-1"
        encrypt        = true
    }
}