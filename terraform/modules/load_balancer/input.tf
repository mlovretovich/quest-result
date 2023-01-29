# name of the application
# 
variable "app_name" {
  type     = string
  nullable = false
}

# fully qualified domain name
# example: myhost.mydomain.com
# 
variable "fqdn" {
  type = string
  validation {
    condition     = length(split(".", var.fqdn)) == 3
    error_message = "Must be valid FQDN [host.domain.com]"
  }
}

# load balancer access logs bucket
# 
variable "lb_access_logs_bucket" {
  type     = string
  nullable = true
}

# subnet ids to associate with the load balancer
#
variable "subnet_ids" {
  type = list(string)
}

# vpc to place the load balancer in
#
variable "vpc_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}