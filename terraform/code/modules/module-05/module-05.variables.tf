variable "admin_username" {
  type        = string
  description = "The name of the key vault secret containing the admin username"
}
variable "key_vault_id" {
  type        = string
  description = "The existing key vault where secrets are stored"
}
variable "resource_group_name" {
  type        = string
  description = "The name of the existing resource group for provisioning resources."
}
variable "location" {
  type        = string
  description = "The name of the Azure Region where resources will be provisioned."
}
variable "vnet_app_01_subnets" {
  type        = map(any)
  description = "The existing subnets defined in the application virtual network."
}

variable "mssql_database_name" {
  type        = string
  description = "The name of the Azure SQL Database to be provisioned"
  default     = "testdb"
}