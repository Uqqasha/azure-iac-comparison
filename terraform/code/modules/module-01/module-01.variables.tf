variable "aad_tenant_id" {
  type        = string
}
variable "arm_client_object_id" {
  type        = string
}
variable "owner_object_id" {
  type        = string
}
variable "resource_group_name" {
  type        = string
}
variable "location" {
  type        = string
}
variable "admin_username" {
  type = string
}
variable "vnet_dns_servers" {
  type        = list
}

## Storage Account Variables
variable "storage_account_name" {
  type = string
  default     = "st"
}
variable "storage_tier" {
  type = string
  default     = "Standard"
}
variable "storage_replication" {
  type = string
  default     = "LRS"
}
variable "storage_kind" {
  type = string
  default     = "StorageV2"
}
variable "storage_container_name" {
  type = string
  default     = "scripts"
}

## Log Analytics Workspace Variables
variable "log_analytics_workspace_name" {
  type = string
  default     = "log-shared-terraform-01"
}
variable "log_analytics_workspace_sku" {
  type = string
  default     = "PerGB2018"
}
variable "log_analytics_workspace_retention_days" {
  type = string
  default     = "30"
}

## Automation Account Variables
variable "automation_account_sku" {
  type = string
  default = "Basic"
}

## Key Vault Variables
variable "key_vault_name" {
  type = string
  default     = "kv"
}
variable "key_vault_sku" {
  type = string
  default     = "standard"
}

## Bastion Variables
variable "bastion_name" {
  type        = string
  default     = "bst-terraform-01"
}
variable "bastion_pip_allocation" {
  type        = string
  default     = "Static"
}
variable "bastion_pip_sku" {
  type        = string
  default     = "Standard"
}

## VNet Variables
variable "vnet_name_m1" {
  type        = string
  default     = "vnet-shared-01"
}
variable "vnet_address_space_m1" {
  type        = string
  default     = "10.1.0.0/16"
}

## Subnets Variables
variable "subnet_adds_address_prefix" {
  type        = string
  default     = "10.1.1.0/24"
}
variable "subnet_AzureBastionSubnet_address_prefix" {
  type        = string
  default     = "10.1.0.0/27"
}
variable "subnet_misc_address_prefix" {
  type        = string
  default     = "10.1.2.0/27"
}
variable "subnet_misc_02_address_prefix" {
  type        = string
  default     = "10.1.3.0/27"
}

## AD DS Virtual Machine Variables
variable "vm_adds_name" {
  type        = string
  default     = "adds1"
}
variable "vm_adds_size" {
  type        = string
  default     = "Standard_B1s"
}
variable "vm_adds_storage_account_type" {
  type        = string
  default     = "Standard_LRS"
}
variable "vm_adds_storage_account_caching" {
  type        = string
  default     = "ReadWrite"
}
variable "vm_adds_image_offer" {
  type        = string
  default     = "WindowsServer"
}
variable "vm_adds_image_publisher" {
  type        = string
  default     = "MicrosoftWindowsServer"
}
variable "vm_adds_image_sku" {
  type        = string
  default     = "2022-datacenter-core-g2"
}
variable "vm_adds_image_version" {
  type        = string
  default     = "Latest"
}