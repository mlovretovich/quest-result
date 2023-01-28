variable "app_name" {
  type     = string
  nullable = false
}

variable "app_version" {
  type     = string
  nullable = false
}

variable "fqdn" {
  type    = string
  default = "quest.brotherhoodwithoutmanners.net"
}
variable "lb_access_logs_bucket" {
  type     = string
  nullable = true
  default  = "mlovretovich-lb-access-logs"
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "lb_target_group_arn" {
  type = string
}

variable "instance_count" {
  type = number
}

variable "ecr_repository_name" {
  type = string
}