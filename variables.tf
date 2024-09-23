variable "location" {
  description = "Azure location for the VM"
  type = string
  default = "canadacentral"
}

variable "tags" {
  description = "Tags that will be applied to every associated VM resource"
  type = map(string)
  default = {}
}

variable "env" {
  description = "(Required) 4 character string defining the environment name prefix for the VM"
  type = string
  default =  "dev"
}

variable "group" {
  description = "(Required) Character string defining the group for the target subscription"
  type = string
  default = "test"
}

variable "project" {
  description = "(Required) Character string defining the project for the target subscription"
  type = string
  default = "test"
}

variable "userDefinedString" {
  description = "(Required) User defined portion value for the name of the VM."
  type = string
  default= "test"
}

variable "serverType" {
  description = "3 character string defining the server type for the VM"
  type = string
  default = "SWJ"
}





variable "windows_vms_cluster" {
  description = "(Required) Cluster configuration for the HA VMs."
  type        = any
  default     = null
}

variable "resource_groups" {
  description = "(Required) Resource group object for the VM"
  type = any
  default = {}
}



variable "subnets" {
  description = "(Required) List of subnet objects for the VM"
  type = any
  default = {}
}

variable "user_data" {
  description = "Base64 encoded file representing user data script for the VM"
  type = any
  default = null
}