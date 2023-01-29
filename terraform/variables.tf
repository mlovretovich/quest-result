variable "app_name" {
  type     = string
  nullable = false
}

variable "app_version" {
  type     = string
  nullable = false
}

variable "instance_count" {
  type     = number
  nullable = false
}

variable "fqdn" {
  type = string
  validation {
    condition     = length(split(".", var.fqdn)) == 3
    error_message = "Must be valid FQDN [host.domain.com]"
  }
  nullable = false
}

# load balancer access logs bucket
# 
variable "lb_access_logs_bucket" {
  type     = string
  nullable = false
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "ecr_repository_name" {
  type     = string
  default  = null
  nullable = true
}