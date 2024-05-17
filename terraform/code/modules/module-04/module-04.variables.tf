variable "admin_username" {
  type        = string
}
variable "key_vault_id" {
  type        = string
}
variable "location" {
  type        = string
}
variable "resource_group_name" {
  type        = string
}
variable "vnet_app_01_subnets" {
  type        = map(any)
}

variable "mysql_database_name" {
  type        = string
  default     = "testdb"
}
variable "mysql_flexible_server_zone" {
  type        = string
  default     = "1"
}