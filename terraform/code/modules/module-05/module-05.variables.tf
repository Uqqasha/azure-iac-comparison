variable "admin_username" {
  type        = string
}
variable "key_vault_id" {
  type        = string
}
variable "resource_group_name" {
  type        = string
}
variable "location" {
  type        = string
}
variable "vnet_app_01_subnets" {
  type        = map(any)
}

variable "mssql_database_name" {
  type        = string
  default     = "testdb"
}