variable "aad_tenant_id" {
  type        = string
  description = "The Microsoft Entra tenant id."
}
variable "subscription_id" {
  type        = string
  description = "The Azure subscription id used to provision resources."
}
variable "arm_client_id" {
  type        = string
  description = "The AppId of the service principal used for authenticating with Azure. Must have a 'Contributor' role assignment."
}
variable "arm_client_secret" {
  type        = string
  description = "The password for the service principal used for authenticating with Azure. Set interactively or using an environment variable 'TF_VAR_arm_client_secret'."
  sensitive   = true
}
variable "arm_client_object_id" {
  type        = string
  description = "The Object ID for the service principal."
}
variable "owner_object_id" {
  type        = string
  description = "The Object ID of Azure CLI signed in User."
  
}
variable "resource_group_name" {
  type        = string
  description = "The name of the new resource group to be provisioned."
}
variable "location" {
  type        = string
  description = "The name of the Azure Region where resources will be provisioned."
}
variable "admin_username" {
  type = string
  description = "Username of admin user."
}

variable "vnet_dns_servers" {
  type        = list
  description = "List of IP addresses of DNS servers."
}