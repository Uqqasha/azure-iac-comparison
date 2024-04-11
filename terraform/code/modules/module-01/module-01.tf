resource "random_string" "azurerm_storage_account_name" {
  length  = 16
  lower   = true
  numeric = false
  special = false
  upper   = false
}

resource "random_password" "admin_password" {
  length  = 16
}

resource "azurerm_storage_account" "st" {
  name                     = "${var.storage_account_name}${random_string.azurerm_storage_account_name.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.storage_tier
  account_replication_type = var.storage_replication
  account_kind             = var.storage_kind
}

resource "azurerm_storage_container" "st_container" {
  name                  = var.storage_container_name
  storage_account_name  = azurerm_storage_account.st.name
  depends_on            = [ azurerm_storage_account.st ]
}

###### Azure Key Vault #####
resource "azurerm_key_vault" "kv" {
  name                       = "${var.key_vault_name}-${random_string.azurerm_storage_account_name.result}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  sku_name                   = var.key_vault_sku
  tenant_id                  = var.aad_tenant_id
  soft_delete_retention_days = 7
  enable_rbac_authorization  = false
  purge_protection_enabled   = false 

  access_policy {
    tenant_id          = var.aad_tenant_id
    object_id          = var.owner_object_id
    secret_permissions = ["Get", "List", "Set", "Delete", "Purge"]
  }

  access_policy {
    tenant_id          = var.aad_tenant_id
    object_id          = var.arm_client_object_id
    secret_permissions = ["Get", "Set", "Delete", "Purge"]
  }
}

# Shared log analytics workspace
resource "azurerm_log_analytics_workspace" "log_analytics_workspace_01" {
  name                = var.log_analytics_workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_workspace_sku
  retention_in_days   = var.log_analytics_workspace_retention_days
}

resource "azurerm_key_vault_secret" "adminuser" {
  name         = "adminuser"
  value        = var.admin_username
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "adminpassword" {
  name         = "adminpassword"
  value        = random_password.admin_password.result
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "storage_account_access_key" {
  name         = azurerm_storage_account.st.name
  value        = azurerm_storage_account.st.primary_access_key
  key_vault_id = azurerm_key_vault.kv.id

  depends_on   = [ azurerm_storage_account.st ]
}

resource "azurerm_key_vault_secret" "log_analytics_workspace_01_primary_shared_key" {
  name  = azurerm_log_analytics_workspace.log_analytics_workspace_01.workspace_id
  value = azurerm_log_analytics_workspace.log_analytics_workspace_01.primary_shared_key
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [ azurerm_log_analytics_workspace.log_analytics_workspace_01 ]
}

##### Azure Automation account #####
# resource "random_id" "automation_account_01_name" {
#   byte_length = 8
# }

# resource "azurerm_automation_account" "automation_account_01" {
#   name                = "auto-${random_id.automation_account_01_name.hex}-01"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   sku_name            = var.automation_account_sku
# }

##### Shared services virtual network, subnets and network security groups #####
resource "azurerm_virtual_network" "vnet_shared_01" {
  name                = var.vnet_name_m1
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.vnet_address_space_m1]
  dns_servers         = var.vnet_dns_servers 
}

resource "azurerm_subnet" "vnet_shared_01_subnets" {
  for_each                                  = local.subnets_M1
  name                                      = each.key
  resource_group_name                       = var.resource_group_name
  virtual_network_name                      = azurerm_virtual_network.vnet_shared_01.name
  address_prefixes                          = [each.value.address_prefix]
  private_endpoint_network_policies_enabled = each.value.private_endpoint_network_policies_enabled

  depends_on = [ azurerm_virtual_network.vnet_shared_01 ]
}

resource "azurerm_network_security_group" "network_security_groups_m1" {
  for_each = azurerm_subnet.vnet_shared_01_subnets

  name                = "nsg-${var.vnet_name_m1}.${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name

  depends_on = [ azurerm_subnet.vnet_shared_01_subnets ]
}

resource "azurerm_subnet_network_security_group_association" "nsg_subnet_associations_m1" {
  for_each = azurerm_subnet.vnet_shared_01_subnets

  subnet_id                 = azurerm_subnet.vnet_shared_01_subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.network_security_groups_m1[each.key].id

  depends_on = [
    # azurerm_bastion_host.bastion_host_01,
    azurerm_network_security_rule.network_security_rules_m1
  ]
}

resource "azurerm_network_security_rule" "network_security_rules_m1" {
  for_each = {
    for network_security_group_rule in local.network_security_group_rules : "${network_security_group_rule.subnet_name}.${network_security_group_rule.nsgrule_name}" => network_security_group_rule
  }

  access                      = each.value.access
  destination_address_prefix  = each.value.destination_address_prefix
  destination_port_range      = length(each.value.destination_port_ranges) == 1 ? each.value.destination_port_ranges[0] : null
  destination_port_ranges     = length(each.value.destination_port_ranges) > 1 ? each.value.destination_port_ranges : null
  direction                   = each.value.direction
  name                        = each.value.nsgrule_name
  network_security_group_name = "nsg-${var.vnet_name_m1}.${each.value.subnet_name}"
  priority                    = each.value.priority
  protocol                    = each.value.protocol
  resource_group_name         = var.resource_group_name
  source_address_prefix       = each.value.source_address_prefix
  source_port_range           = length(each.value.source_port_ranges) == 1 ? each.value.source_port_ranges[0] : null
  source_port_ranges          = length(each.value.source_port_ranges) > 1 ? each.value.source_port_ranges : null

  depends_on = [
    azurerm_network_security_group.network_security_groups_m1
  ]
}

##### Bastion #####
resource "azurerm_bastion_host" "bastion_host_01" {
  name                = var.bastion_name
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                 = "ipc-${var.bastion_name}"
    subnet_id            = azurerm_subnet.vnet_shared_01_subnets["AzureBastionSubnet"].id
    public_ip_address_id = azurerm_public_ip.bastion_host_01.id
  }

  depends_on = [ azurerm_public_ip.bastion_host_01, azurerm_subnet.vnet_shared_01_subnets ]
}
# # Dedicated public ip for bastion
resource "azurerm_public_ip" "bastion_host_01" {
  name                = "pip-${var.bastion_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.bastion_pip_allocation
  sku                 = var.bastion_pip_sku
}

# ##### AD DS Virtual Machine #####
resource "azurerm_windows_virtual_machine" "vm_adds" {
  name                     = "vm-${var.vm_adds_name}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  size                     = var.vm_adds_size
  admin_username           = azurerm_key_vault_secret.adminuser.value
  admin_password           = azurerm_key_vault_secret.adminpassword.value
  network_interface_ids    = [azurerm_network_interface.vm_adds_nic_01.id]
  enable_automatic_updates = true
  patch_mode               = "AutomaticByOS"
  # depends_on               = [azurerm_automation_account.automation_account_01]

  os_disk {
    caching              = var.vm_adds_storage_account_caching
    storage_account_type = var.vm_adds_storage_account_type
  }

  source_image_reference {
    publisher = var.vm_adds_image_publisher
    offer     = var.vm_adds_image_offer
    sku       = var.vm_adds_image_sku
    version   = var.vm_adds_image_version
  }

  depends_on = [ azurerm_network_interface.vm_adds_nic_01 ]
}

resource "azurerm_network_interface" "vm_adds_nic_01" {
  name                = "nic-${var.vm_adds_name}-1"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipc-${var.vm_adds_name}-1"
    subnet_id                     = azurerm_subnet.vnet_shared_01_subnets["snet-adds-01"].id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [ azurerm_subnet.vnet_shared_01_subnets ]
}