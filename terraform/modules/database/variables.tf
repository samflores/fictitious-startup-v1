variable "username" {
  description = "Database administrator username"
  type        = string
}

variable "password" {
  description = "Database administrator password"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the database will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "The subnet IDs where the database will be deployed"
  type        = list(string)
}

variable "subnet_group_name" {
  description = "The name of the subnet group where the database will be deployed"
  type        = string
}
