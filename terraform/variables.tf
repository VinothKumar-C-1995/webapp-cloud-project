variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev / staging / prod)"
  type        = string
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "webapp"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "desired_count" {
  description = "Desired ECS task count"
  type        = number
  default     = 2
}

variable "min_count" {
  description = "Minimum ECS task count"
  type        = number
  default     = 1
}

variable "max_count" {
  description = "Maximum ECS task count"
  type        = number
  default     = 6
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 3000
}

variable "alert_email" {
  description = "Email for CloudWatch alarm notifications"
  type        = string
}
