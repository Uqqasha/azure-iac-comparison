variable "resource_group_name" {
  type        = string
}
variable "location" {
  type        = string
}
variable "admin_username" {
  type        = string
}
variable "key_vault_id" {
  type        = string
}
variable "vnet_app_01_subnets" {
  type        = map(any)
}

variable "vm_mssql_win_data_disk_config" {
  type        = map(any)
  default = {
    sqldata = {
      name         = "vol_sqldata_M",
      disk_size_gb = "128",
      lun          = "0",
      caching      = "ReadOnly"
    },
    sqllog = {
      name         = "vol_sqllog_L",
      disk_size_gb = "32",
      lun          = "1",
      caching      = "None"
    }
  }
}
variable "vm_mssql_win_image_offer" {
  type        = string
  default     = "sql2022-ws2022"
}
variable "vm_mssql_win_image_publisher" {
  type        = string
  default     = "MicrosoftSQLServer"
}
variable "vm_mssql_win_image_sku" {
  type        = string
  default     = "sqldev-gen2"
}
variable "vm_mssql_win_image_version" {
  type        = string
  default     = "Latest"
}
variable "vm_mssql_win_name" {
  type        = string
  default     = "mssqlwin1"
}
variable "vm_mssql_win_size" {
  type        = string
  default     = "Standard_B1ms"
}
variable "vm_mssql_win_storage_account_type" {
  type        = string
  default     = "StandardSSD_LRS"
}