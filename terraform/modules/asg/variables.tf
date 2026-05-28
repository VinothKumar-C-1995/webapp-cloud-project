variable "app_name"      { type = string }
variable "ecs_cluster"   { type = string }
variable "ecs_service"   { type = string }
variable "min_count"     { type = number }
variable "max_count"     { type = number }
variable "alb_arn_suffix"{ type = string }
variable "tg_arn_suffix" { type = string }
