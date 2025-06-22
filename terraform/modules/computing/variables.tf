variable "vpc_id" {
  description = "The VPC ID where the instance will be deployed"
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID where the instance will be deployed"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID for the instance"
  type        = string
}

variable "instance_type" {
  description = "The type of instance to be used"
  type        = string
}

variable "instance_profile_names" {
  description = "Optional list of IAM instance profile names to assign to EC2 instances"
  type        = list(string)
  default     = []
}

variable "ip_allowed_to_access_db" {
  description = "IP allowed to access DB"
  type        = string
}
