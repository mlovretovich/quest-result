variable "app_name" {
  type     = string
  nullable = false
}

variable "app_version" {
  type     = string
  nullable = false
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

variable "tags" {
  type    = map(string)
  default = {}
}