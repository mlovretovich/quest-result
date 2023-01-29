variable "app_name" {
  type     = string
  nullable = false
}

variable "tags" {
  type    = map(string)
  default = {}
}