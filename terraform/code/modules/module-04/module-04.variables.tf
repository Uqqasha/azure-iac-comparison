variable "admin_username" {
  type        = string
  description = "The name of the key vault secret containing the admin username"
}
variable "key_vault_id" {
  type        = string
  description = "The existing key vault where secrets are stored"
}
variable "location" {
  type        = string
  description = "The name of the Azure Region where resources will be provisioned."
}
variable "resource_group_name" {
  type        = string
  description = "The name of the existing resource group for provisioning resources."
}
variable "vnet_app_01_subnets" {
  type        = map(any)
  description = "The existing subnets defined in the application virtual network."
}

variable "mysql_database_name" {
  type        = string
  description = "The name of the Azure MySQL Database to be provisioned"
  default     = "testdb"
}
variable "mysql_flexible_server_zone" {
  type        = string
  description = "The availability zone used to deploy the Azure Database for MySQL - Flexible Server."
  default     = "1"
}