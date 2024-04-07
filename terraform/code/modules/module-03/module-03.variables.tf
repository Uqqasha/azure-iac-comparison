variable "resource_group_name" {
  type        = string
  description = "The name of the new resource group to be provisioned."
}
variable "location" {
  type        = string
  description = "The name of the Azure Region where resources will be provisioned."
}
variable "admin_username" {
  type        = string
}
variable "key_vault_id" {
  type        = string
}
variable "vnet_app_01_subnets" {
  type        = map(any)
  description = "The existing subnets defined in the application virtual network."
}

variable "vm_mssql_win_data_disk_config" {
  type        = map(any)
  description = "Data disk configuration for SQL Server virtual machine."
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
  description = "The offer type of the virtual machine image used to create the database server VM"
  default     = "sql2022-ws2022"
}
variable "vm_mssql_win_image_publisher" {
  type        = string
  description = "The publisher for the virtual machine image used to create the database server VM"
  default     = "MicrosoftSQLServer"
}
variable "vm_mssql_win_image_sku" {
  type        = string
  description = "The sku of the virtual machine image used to create the database server VM"
  default     = "sqldev-gen2"
}
variable "vm_mssql_win_image_version" {
  type        = string
  description = "The version of the virtual machine image used to create the database server VM"
  default     = "Latest"
}
variable "vm_mssql_win_name" {
  type        = string
  description = "The name of the database server VM"
  default     = "mssqlwin1"
}
variable "vm_mssql_win_size" {
  type        = string
  description = "The size of the virtual machine"
  default     = "Standard_B1ms"
}
variable "vm_mssql_win_storage_account_type" {
  type        = string
  description = "The storage replication type to be used for the VMs OS disk"
  default     = "StandardSSD_LRS"
}