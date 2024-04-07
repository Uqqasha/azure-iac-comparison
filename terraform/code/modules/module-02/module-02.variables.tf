variable "subscription_id" {
  type        = string
  description = "The Azure subscription id used to provision resources."
}
variable "resource_group_name" {
  type        = string
  description = "The name of the new resource group to be provisioned."
}
variable "location" {
  type        = string
  description = "The name of the Azure Region where resources will be provisioned."
}
variable "vnet_name_m1" {
  type        = string
}
variable "vnet_id_m1" {
  type        = string
}
variable "vnet_dns_servers" {
  type        = list
  description = "List of IP addresses of DNS servers."
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
  description = "The address space in CIDR notation for the new application virtual network."
  default     = "10.2.0.0/16"
}
variable "vnet_name_m2" {
  type        = string
  description = "The name of the application virtual network."
  default     = "vnet-app-01"
}
variable "subnet_application_address_prefix" {
  type        = string
  description = "The address prefix for the application subnet."
  default     = "10.2.0.0/24"
}
variable "subnet_database_address_prefix" {
  type        = string
  description = "The address prefix for the database subnet."
  default     = "10.2.1.0/24"
}
variable "subnet_misc_03_address_prefix" {
  type        = string
  description = "The address prefix for the MySQL subnet."
  default     = "10.2.3.0/24"
}
variable "subnet_privatelink_address_prefix" {
  type        = string
  description = "The address prefix for the PrivateLink subnet."
  default     = "10.2.2.0/24"
}

## Linux Jumpbox VM variables
variable "vm_jumpbox_linux_name" {
  type        = string
  description = "The name of the VM"
  default     = "jumplinux1"
}
variable "vm_jumpbox_linux_size" {
  type        = string
  description = "The size of the virtual machine"
  default     = "Standard_B1s"
}
variable "vm_jumpbox_linux_image_offer" {
  type        = string
  description = "The offer type of the virtual machine image used to create the VM"
  default     = "0001-com-ubuntu-server-jammy"
}
variable "vm_jumpbox_linux_image_publisher" {
  type        = string
  description = "The publisher for the virtual machine image used to create the VM"
  default     = "Canonical"
}
variable "vm_jumpbox_linux_image_sku" {
  type        = string
  description = "The sku of the virtual machine image used to create the VM"
  default     = "22_04-lts-gen2"
}
variable "vm_jumpbox_linux_image_version" {
  type        = string
  description = "The version of the virtual machine image used to create the VM"
  default     = "Latest"
}
variable "vm_jumpbox_linux_storage_account_type" {
  type        = string
  description = "The storage replication type to be used for the VMs OS and data disks"
  default     = "Standard_LRS"
}

## Windows Jumpbox VM variables
variable "vm_jumpbox_win_name" {
  type        = string
  description = "The name of the VM"
  default     = "jumpwin1"
}
variable "vm_jumpbox_win_size" {
  type        = string
  description = "The size of the virtual machine."
  default     = "Standard_B1s"
}
variable "vm_jumpbox_win_image_publisher" {
  type        = string
  description = "The publisher for the virtual machine image used to create the VM"
  default     = "MicrosoftWindowsServer"
}
variable "vm_jumpbox_win_image_offer" {
  type        = string
  description = "The offer type of the virtual machine image used to create the VM"
  default     = "WindowsServer"
}
variable "vm_jumpbox_win_image_sku" {
  type        = string
  description = "The sku of the virtual machine image used to create the VM"
  default     = "2022-datacenter-g2"
}
variable "vm_jumpbox_win_image_version" {
  type        = string
  description = "The version of the virtual machine image used to create the VM"
  default     = "Latest"
}
variable "vm_jumpbox_win_storage_account_type" {
  type        = string
  description = "The storage replication type to be used for the VMs OS and data disks."
  default     = "Standard_LRS"
}

## File Share variables
variable "storage_share_name" {
  type        = string
  description = "The name of the Azure Files share to be provisioned."
  default     = "myfileshare"
}
variable "storage_share_quota_gb" {
  type        = string
  description = "The storage quota for the Azure Files share to be provisioned in GB."
  default     = "1024"
}