storage_account_name   = "st"
storage_tier           = "Standard"
storage_replication    = "LRS"
storage_kind           = "StorageV2"
storage_container_name = "scripts"

log_analytics_workspace_name           = "log-shared-terraform-01"
log_analytics_workspace_sku            = "PerGB2018"
log_analytics_workspace_retention_days = "30"

automation_account_sku = "Basic"

key_vault_name = "kv"
key_vault_sku  = "standard"
admin_username = "bootstrapadmin"

vnet_name                                = "vnet-shared-01"
vnet_address_space                       = "10.1.0.0/16"
vnet_dns_servers                         = ["10.1.1.4", "168.63.129.16"]
subnet_adds_address_prefix               = "10.1.1.0/24"
subnet_AzureBastionSubnet_address_prefix = "10.1.0.0/27"
subnet_misc_address_prefix               = "10.1.2.0/24"
subnet_misc_02_address_prefix            = "10.1.3.0/24"

bastion_name           = "bst-terraform-01"
bastion_pip_allocation = "Static"
bastion_pip_sku        = "Standard"

vm_adds_name                    = "adds1"
vm_adds_size                    = "Standard_B2s"
vm_adds_storage_account_type    = "Standard_LRS"
vm_adds_storage_account_caching = "ReadWrite"
vm_adds_image_offer             = "WindowsServer"
vm_adds_image_publisher         = "MicrosoftWindowsServer"
vm_adds_image_sku               = "2022-datacenter-core-g2"
vm_adds_image_version           = "Latest"