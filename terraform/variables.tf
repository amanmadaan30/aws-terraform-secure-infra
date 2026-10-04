variable "db_password" {
  description = "Master password for the RDS instance"
  type        = string
  sensitive   = true
}

variable "admin_cidr" {
  description = "CIDR block permitted to reach the database directly"
  type        = string
}

variable "vpc_id" {
  description = "VPC in which to create resources"
  type        = string
}
