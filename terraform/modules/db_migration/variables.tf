variable "subnet_ids" {
  description = "The subnet IDs where the dms instance will be deployed"
  type        = list(string)
}

variable "source_db_server" {
  description = "Source database server hostname"
  type        = string
}

variable "source_db_username" {
  description = "Source database username"
  type        = string
}

variable "source_db_password" {
  description = "Source database password"
  type        = string
}

variable "source_db_name" {
  description = "Source database name"
  type        = string
}

variable "target_db_server" {
  description = "Target database server hostname"
  type        = string
}

variable "target_db_username" {
  description = "Target database username"
  type        = string
}

variable "target_db_password" {
  description = "Target database password"
  type        = string
}

variable "target_db_name" {
  description = "Target database name"
  type        = string
}
