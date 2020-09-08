#  Init GCP
provider "google" {
 credentials = file(var.auth_file)
 project     = var.project_id
 region      = var.region
}

module "jvb" {
  source            = "../modules/gcp_jvb_autoscale"
  project_id        = var.project_id
  region            = var.region
  app_prefix        = var.app_prefix
  network_name      = var.network_name
  min_instances     = var.min_instances
  max_instances     = var.max_instances
  machine_type      = var.machine_type
  app_password      = var.app_password
  autoscale_cpu_target = var.autoscale_cpu_target
}

variable "auth_file"{
  type = string
  default = "./creds.json"
}

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
