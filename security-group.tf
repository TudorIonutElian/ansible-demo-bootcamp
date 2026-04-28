/**********************************************************
  # Security group allowing HTTP inbound and all outbound
  # Required for the sample website to be publicly accessible
**********************************************************/

resource "aws_security_group" "ssm_web_sg" {
  name        = "ssm-web-sg"
  description = "Allow HTTP and SSH inbound traffic for SSM demo website"

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
    Name        = "ssm-web-sg"
    Environment = "Development-${var.build_number}"
  }
}
