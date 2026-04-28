/**********************************************************
  # Security group allowing HTTP and SSH inbound and all outbound
  # Required for the website to be publicly accessible and Ansible deployment
**********************************************************/

resource "aws_security_group" "ssm_web_sg" {
  name        = "ansible-web-sg"
  description = "Allow HTTP and SSH inbound traffic for AWS Ansible demo website"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "ansible-web-sg"
    Environment = "Development-${var.build_number}"
  }

  lifecycle {
    create_before_destroy = true
  }
}
