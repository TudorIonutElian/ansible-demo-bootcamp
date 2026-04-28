/**********************************************************
  # Create 5 small EC2 Instances for React app deployment
**********************************************************/
resource "aws_instance" "web_instances" {
  ami                         = data.aws_ami.ssm_ami_filter.id
  instance_type               = "t3.small"
  key_name                    = aws_key_pair.ssm_key.key_name
  count                       = 5
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm_profile.name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.ssm_web_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    set -e

    # Ensure SSM agent is running (pre-installed on standard AL2023)
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent

    # Install Python3 for Ansible
    dnf install -y python3 python3-pip

    # Create deployment directory
    mkdir -p /opt/webapp
    chmod 755 /opt/webapp

    echo "Setup complete on $(hostname) at $(date)" > /var/log/user-data-complete.log
  EOF

  tags = {
    Name        = "Web Instance ${count.index + 1}"
    Environment = "Development-${var.build_number}"
    Role        = "web-server"
    AnsibleManaged = "true"
  }
}