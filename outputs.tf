output "instance_ids" {
  description = "IDs of the web EC2 instances"
  value       = aws_instance.web_instances[*].id
}

output "instance_public_ips" {
  description = "Public IP addresses of the web EC2 instances"
  value       = aws_instance.web_instances[*].public_ip
}

output "instance_private_ips" {
  description = "Private IP addresses of the web EC2 instances"
  value       = aws_instance.web_instances[*].private_ip
}

output "website_urls" {
  description = "URLs to access the React app on each instance"
  value       = [for ip in aws_instance.web_instances[*].public_ip : "http://${ip}"]
}

output "security_group_id" {
  description = "ID of the web security group"
  value       = aws_security_group.ssm_web_sg.id
}

output "ssh_private_key_path" {
  description = "Path to SSH private key for Ansible"
  value       = "~/.ssh/ansible-demo-key.pem"
}

output "ssh_private_key" {
  description = "SSH private key for Ansible connections"
  value       = tls_private_key.ssm_key_pair.private_key_pem
  sensitive   = true
}

output "ansible_inventory" {
  description = "Ansible inventory in INI format"
  value = <<-EOT
[web_servers]
${join("\n", [for idx, ip in aws_instance.web_instances[*].public_ip : "${ip} ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/ansible-demo-key.pem"])}

[web_servers:vars]
ansible_python_interpreter=/usr/bin/python3
EOT
}
