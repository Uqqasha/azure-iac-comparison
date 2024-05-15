variable "subscription_id" {
  type        = string
}
variable "resource_group_name" {
  type        = string
}
variable "location" {
  type        = string
}
variable "vnet_name_m1" {
  type        = string
}
variable "vnet_id_m1" {
  type        = string
}
variable "vnet_dns_servers" {
  type        = list
}
variable "admin_username" {
  type        = string
}
variable "key_vault_id" {
  type        = string
}
variable "storage_account_name" {
  type        = string
}


## VNet and Subnet variables
variable "vnet_address_space_m2" {
  type        = string
  default     = "10.2.0.0/16"
}
variable "vnet_name_m2" {
  type        = string
  default     = "vnet-app-01"
}
variable "subnet_application_address_prefix" {
  type        = string
  default     = "10.2.0.0/24"
}
variable "subnet_database_address_prefix" {
  type        = string
  default     = "10.2.1.0/24"
}
variable "subnet_misc_03_address_prefix" {
  type        = string
  default     = "10.2.3.0/24"
}
variable "subnet_privatelink_address_prefix" {
  type        = string
  default     = "10.2.2.0/24"
}

## Linux Jumpbox VM variables
variable "vm_jumpbox_linux_name" {
  type        = string
  default     = "jumplinux1"
}
variable "vm_jumpbox_linux_size" {
  type        = string
  default     = "Standard_B1s"
}
variable "vm_jumpbox_linux_image_offer" {
  type        = string
  default     = "0001-com-ubuntu-server-jammy"
}
variable "vm_jumpbox_linux_image_publisher" {
  type        = string
  default     = "Canonical"
}
variable "vm_jumpbox_linux_image_sku" {
  type        = string
  default     = "22_04-lts-gen2"
}
variable "vm_jumpbox_linux_image_version" {
  type        = string
  default     = "Latest"
}
variable "vm_jumpbox_linux_storage_account_type" {
  type        = string
  default     = "Standard_LRS"
}

## Windows Jumpbox VM variables
variable "vm_jumpbox_win_name" {
  type        = string
  default     = "jumpwin1"
}
variable "vm_jumpbox_win_size" {
  type        = string
  default     = "Standard_B1s"
}
variable "vm_jumpbox_win_image_publisher" {
  type        = string
  default     = "MicrosoftWindowsServer"
}
variable "vm_jumpbox_win_image_offer" {
  type        = string
  default     = "WindowsServer"
}
variable "vm_jumpbox_win_image_sku" {
  type        = string
  default     = "2022-datacenter-g2"
}
variable "vm_jumpbox_win_image_version" {
  type        = string
  default     = "Latest"
}
variable "vm_jumpbox_win_storage_account_type" {
  type        = string
  default     = "Standard_LRS"
}

## File Share variables
variable "storage_share_name" {
  type        = string
  default     = "myfileshare"
}
variable "storage_share_quota_gb" {
  type        = string
  default     = "1024"
}