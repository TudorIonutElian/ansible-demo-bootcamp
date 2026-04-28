/**********************************************************
  # Path: key-pair.tf
  # This resource creates a TLS private key
  # The key pair is used for SSH access to EC2 instances via Ansible
**********************************************************/
resource "tls_private_key" "ssm_key_pair" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

/*********************************************************
  # Path: key-pair.tf
  # This resource creates a key pair for EC2 instances
  # Used by Ansible for SSH connections
  # The private key is saved in the local file system
**********************************************************/
resource "aws_key_pair" "ssm_key" {
  key_name   = "ansible-demo-key"
  public_key = tls_private_key.ssm_key_pair.public_key_openssh

  provisioner "local-exec" {
    command = <<-EOT
      mkdir -p ~/.ssh
      echo '${tls_private_key.ssm_key_pair.private_key_pem}' > ~/.ssh/ansible-demo-key.pem
      chmod 600 ~/.ssh/ansible-demo-key.pem
    EOT
  }
}