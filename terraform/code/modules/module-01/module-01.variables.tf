variable "aad_tenant_id" {
  type        = string
  description = "The Microsoft Entra tenant id."
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

## Storage Account Variables
variable "storage_account_name" {
  type = string
  description = "The name prefix of the new storage account to be provisioned"
  default     = "st"
}
variable "storage_tier" {
  type = string
  description = "Defines the Tier to use for this storage account. Valid options are Standard and Premium."
  default     = "Standard"
}
variable "storage_replication" {
  type = string
  description = "Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS."
  default     = "LRS"
}
variable "storage_kind" {
  type = string
  description = "Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2."
  default     = "StorageV2"
}
variable "storage_container_name" {
  type = string
  description = "The name of the Container which should be created within the Storage Account."
  default     = "scripts"
}

## Log Analytics Workspace Variables
variable "log_analytics_workspace_name" {
  type = string
  description = "The name of the new Log Analytics Workspace to be provisioned."
  default     = "log-shared-terraform-01"
}
variable "log_analytics_workspace_sku" {
  type = string
  description = "Specifies the SKU of the Log Analytics Workspace. Possible values are Free, PerNode, Premium, Standard, Standalone, Unlimited, CapacityReservation, and PerGB2018."
  default     = "PerGB2018"
}
variable "log_analytics_workspace_retention_days" {
  type = string
  description = "The workspace data retention in days."
  default     = "30"
}

## Automation Account Variables
variable "automation_account_sku" {
  type = string
  description = "The SKU of the account. Possible values are Basic and Free."
  default = "Basic"
}

## Key Vault Variables
variable "key_vault_name" {
  type = string
  description = "The name prefix of the new key vault to be provisioned"
  default     = "kv"
}
variable "key_vault_sku" {
  type = string
  description = "The Name of the SKU used for this Key Vault. Possible values are standard and premium."
  default     = "standard"
}

## Bastion Variables
variable "bastion_name" {
  type        = string
  description = "The name of Bastion."
  default     = "bst-terraform-01"
}
variable "bastion_pip_allocation" {
  type        = string
  description = "Defines the allocation method for this IP address. Possible values are Static or Dynamic."
  default     = "Static"
}
variable "bastion_pip_sku" {
  type        = string
  description = "The SKU of the Public IP. Accepted values are Basic and Standard."
  default     = "Standard"
}

## VNet Variables
variable "vnet_name_m1" {
  type        = string
  description = "The name of the new virtual network to be provisioned."
  default     = "vnet-shared-01"
}
variable "vnet_address_space_m1" {
  type        = string
  description = "The address space in CIDR notation for the new virtual network."
  default     = "10.1.0.0/16"
}

## Subnets Variables
variable "subnet_adds_address_prefix" {
  type        = string
  description = "The address prefix for the AD Domain Services subnet."
  default     = "10.1.1.0/24"
}
variable "subnet_AzureBastionSubnet_address_prefix" {
  type        = string
  description = "The address prefix for the AzureBastionSubnet subnet."
  default     = "10.1.0.0/27"
}
variable "subnet_misc_address_prefix" {
  type        = string
  description = "The address prefix for the miscellaneous subnet."
  default     = "10.1.2.0/27"
}
variable "subnet_misc_02_address_prefix" {
  type        = string
  description = "The address prefix for the miscellaneous 2 subnet."
  default     = "10.1.3.0/27"
}

## AD DS Virtual Machine Variables
variable "vm_adds_name" {
  type        = string
  description = "The name of the VM"
  default     = "adds1"
}
variable "vm_adds_size" {
  type        = string
  description = "The size of the virtual machine."
  default     = "Standard_B1s"
}
variable "vm_adds_storage_account_type" {
  type        = string
  description = "The storage replication type to be used for the VMs OS and data disks."
  default     = "Standard_LRS"
}
variable "vm_adds_storage_account_caching" {
  type        = string
  description = "The storage replication type to be used for the VMs OS and data disks."
  default     = "ReadWrite"
}
variable "vm_adds_image_offer" {
  type        = string
  description = "The offer type of the virtual machine image used to create the VM"
  default     = "WindowsServer"
}
variable "vm_adds_image_publisher" {
  type        = string
  description = "The publisher for the virtual machine image used to create the VM"
  default     = "MicrosoftWindowsServer"
}
variable "vm_adds_image_sku" {
  type        = string
  description = "The sku of the virtual machine image used to create the VM"
  default     = "2022-datacenter-core-g2"
}
variable "vm_adds_image_version" {
  type        = string
  description = "The version of the virtual machine image used to create the VM"
  default     = "Latest"
}