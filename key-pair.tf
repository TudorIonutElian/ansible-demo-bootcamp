/**********************************************************
  # Path: key-pair.tf
  # This resource creates a tls tls_private_key
  # The key pair is used to connect to the SSM instance
**********************************************************/
resource "tls_private_key" "ssm_key_pair" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

/*********************************************************
  # Path: key-pair.tf
  # This resource creates a key pair for the SSM instance
  # The key pair is used to connect to the SSM instance
  # The key pair is saved in the local file system
**********************************************************/
resource "aws_key_pair" "ssm_key" {
  key_name   = "ssm_key_pair"
  public_key = tls_private_key.ssm_key_pair.public_key_openssh

  provisioner "local-exec" {
    command = <<-EOT
      mkdir -p ~/.ssh
      echo '${tls_private_key.ssm_key_pair.private_key_pem}' > ~/.ssh/ssm-key.pem
      chmod 600 ~/.ssh/ssm-key.pem
    EOT
  }
}