variable "startsWith" {
  description = "The prefix of the AMI name"
  type        = string
  default     = "al2023-ami"
}

variable "endsWith" {
  description = "The suffix of the AMI name"
  type        = string
  default     = "x86_64"
}

variable "architecture" {
  description = "The architecture of the AMI"
  type        = string
  default     = "x86_64"
}

variable "build_number" {
  description = "The build number executed by Github CI/CD pipeline"
  type        = string
}