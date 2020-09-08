variable "region" {
  type = string
}

variable "project_id" {
  type = string
}

variable "app_prefix" {
  type = string
}

variable "app_password" {
  type = string
}

variable "machine_type"{
  type = string
}

variable "min_instances" {
  type = number
}

variable "max_instances" {
  type = number
}

variable "network_name" {
  type = string
}

variable "autoscale_cpu_target" {
  type = number
}
