# Application virtual network, subnets and network security groups

data "azurerm_key_vault_secret" "adminpassword" {
  name         = "adminpassword"
  key_vault_id = var.key_vault_id
}

resource "azurerm_virtual_network" "vnet_app_01" {
  name                = var.vnet_name_m2
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.vnet_address_space_m2]
  dns_servers         = var.vnet_dns_servers
}

resource "azurerm_subnet" "vnet_app_01_subnets" {
  for_each                                  = local.subnets_m2
  name                                      = each.key
  resource_group_name                       = var.resource_group_name
  virtual_network_name                      = azurerm_virtual_network.vnet_app_01.name
  address_prefixes                          = [each.value.address_prefix]
  private_endpoint_network_policies_enabled = each.value.private_endpoint_network_policies_enabled
}

resource "azurerm_network_security_group" "network_security_groups_m2" {
  for_each = azurerm_subnet.vnet_app_01_subnets

  name                = "nsg-${var.vnet_name_m2}.${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet_network_security_group_association" "nsg_subnet_associations_m2" {
  for_each = azurerm_subnet.vnet_app_01_subnets

  subnet_id                 = azurerm_subnet.vnet_app_01_subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.network_security_groups_m2[each.key].id

  depends_on = [
    azurerm_network_security_rule.network_security_rules_m2
  ]
}

resource "azurerm_network_security_rule" "network_security_rules_m2" {
  for_each = {
    for network_security_group_rule in local.network_security_group_rules_m2 : "${network_security_group_rule.subnet_name}.${network_security_group_rule.nsgrule_name}" => network_security_group_rule
  }

  access                      = each.value.access
  destination_address_prefix  = each.value.destination_address_prefix
  destination_port_range      = length(each.value.destination_port_ranges) == 1 ? each.value.destination_port_ranges[0] : null
  destination_port_ranges     = length(each.value.destination_port_ranges) > 1 ? each.value.destination_port_ranges : null
  direction                   = each.value.direction
  name                        = each.value.nsgrule_name
  network_security_group_name = "nsg-${var.vnet_name_m2}.${each.value.subnet_name}"
  priority                    = each.value.priority
  protocol                    = each.value.protocol
  resource_group_name         = var.resource_group_name
  source_address_prefix       = each.value.source_address_prefix
  source_port_range           = length(each.value.source_port_ranges) == 1 ? each.value.source_port_ranges[0] : null
  source_port_ranges          = length(each.value.source_port_ranges) > 1 ? each.value.source_port_ranges : null

  depends_on = [
    azurerm_network_security_group.network_security_groups_m2
  ]
}

resource "azurerm_virtual_network_peering" "vnet_shared_01_to_vnet_app_01_peering" {
  name                         = "vnet_shared_01_to_vnet_app_01_peering"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = var.vnet_name_m1
  remote_virtual_network_id    = azurerm_virtual_network.vnet_app_01.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  depends_on                   = [azurerm_network_security_rule.network_security_rules_m2]
}

resource "azurerm_virtual_network_peering" "vnet_app_01_to_vnet_shared_01_peering" {
  name                         = "vnet_app_01_to_vnet_shared_01_peering"
  resource_group_name          = azurerm_virtual_network.vnet_app_01.resource_group_name
  virtual_network_name         = azurerm_virtual_network.vnet_app_01.name
  remote_virtual_network_id    = var.vnet_id_m1
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  depends_on                   = [azurerm_network_security_rule.network_security_rules_m2]
}

# Private DNS zones
resource "azurerm_private_dns_zone" "private_dns_zones" {
  for_each            = toset(local.private_dns_zones)
  name                = each.value
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_virtual_network_links_vnet_app_01" {
  for_each              = azurerm_private_dns_zone.private_dns_zones
  name                  = "pdnslnk-${each.value.name}-${azurerm_virtual_network.vnet_app_01.name}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = each.value.name
  virtual_network_id    = azurerm_virtual_network.vnet_app_01.id

  depends_on            = [
    azurerm_virtual_network_peering.vnet_app_01_to_vnet_shared_01_peering, 
    azurerm_virtual_network_peering.vnet_shared_01_to_vnet_app_01_peering
  ]
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_virtual_network_links_vnet_shared_01" {
  for_each              = azurerm_private_dns_zone.private_dns_zones
  name                  = "pdnslnk-${each.value.name}-${var.vnet_name_m1}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = each.value.name
  virtual_network_id    = var.vnet_id_m1
  
  depends_on            = [
    azurerm_virtual_network_peering.vnet_app_01_to_vnet_shared_01_peering, 
    azurerm_virtual_network_peering.vnet_shared_01_to_vnet_app_01_peering
  ]
}

# Windows jumpbox virtual machine
# resource "azurerm_windows_virtual_machine" "vm_jumpbox_win" {
#   name                     = var.vm_jumpbox_win_name
#   resource_group_name      = var.resource_group_name
#   location                 = var.location
#   size                     = var.vm_jumpbox_win_size
#   admin_username           = var.admin_username
#   admin_password           = data.azurerm_key_vault_secret.adminpassword.value
#   network_interface_ids    = [azurerm_network_interface.vm_jumpbox_win_nic_01.id]
#   patch_mode               = "AutomaticByOS"

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = var.vm_jumpbox_win_storage_account_type
#   }

#   source_image_reference {
#     publisher = var.vm_jumpbox_win_image_publisher
#     offer     = var.vm_jumpbox_win_image_offer
#     sku       = var.vm_jumpbox_win_image_sku
#     version   = var.vm_jumpbox_win_image_version
#   }

#   depends_on = [ azurerm_private_dns_zone_virtual_network_link.private_dns_zone_virtual_network_links_vnet_app_01 ]
# }

# Nics
resource "azurerm_network_interface" "vm_jumpbox_win_nic_01" {
  name                = "nic-${var.vm_jumpbox_win_name}-1"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipc-${var.vm_jumpbox_win_name}-1"
    subnet_id                     = azurerm_subnet.vnet_app_01_subnets["snet-app-01"].id
    private_ip_address_allocation = "Dynamic"
  }
}

# Linux virtual machine
resource "azurerm_linux_virtual_machine" "vm_jumpbox_linux" {
  name                  = var.vm_jumpbox_linux_name
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = var.vm_jumpbox_linux_size
  admin_username        = var.admin_username
  admin_password        = data.azurerm_key_vault_secret.adminpassword.value
  disable_password_authentication = false
  network_interface_ids = [azurerm_network_interface.vm_jumbox_linux_nic_01.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.vm_jumpbox_linux_storage_account_type
  }

  source_image_reference {
    publisher = var.vm_jumpbox_linux_image_publisher
    offer     = var.vm_jumpbox_linux_image_offer
    sku       = var.vm_jumpbox_linux_image_sku
    version   = var.vm_jumpbox_linux_image_version
  }

  identity {
    type = "SystemAssigned"
  }
}

# Nics
resource "azurerm_network_interface" "vm_jumbox_linux_nic_01" {
  name                = "nic-${var.vm_jumpbox_linux_name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipc-${var.vm_jumpbox_linux_name}"
    subnet_id                     = azurerm_subnet.vnet_app_01_subnets["snet-app-01"].id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    azurerm_subnet_network_security_group_association.nsg_subnet_associations_m2
  ]
}

resource "azurerm_key_vault_access_policy" "vm_jumpbox_linux_secrets_get" {
  key_vault_id       = var.key_vault_id
  tenant_id          = azurerm_linux_virtual_machine.vm_jumpbox_linux.identity[0].tenant_id
  object_id          = azurerm_linux_virtual_machine.vm_jumpbox_linux.identity[0].principal_id
  secret_permissions = ["Get"]
}

# Azure Files share
resource "azurerm_storage_share" "storage_share_01" {
  name                 = var.storage_share_name
  storage_account_name = var.storage_account_name
  quota                = var.storage_share_quota_gb
}

# Azure Files private endpoint
resource "azurerm_private_endpoint" "storage_account_01_file" {
  name                = "pend-${var.storage_account_name}-file"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = azurerm_subnet.vnet_app_01_subnets["snet-privatelink-01"].id

  private_service_connection {
    name                           = "azure_files"
    private_connection_resource_id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Storage/storageAccounts/${var.storage_account_name}"
    is_manual_connection           = false
    subresource_names              = ["file"]
  }

  depends_on = [
    azurerm_subnet_network_security_group_association.nsg_subnet_associations_m2
  ]
}

resource "azurerm_private_dns_a_record" "storage_account_01_file" {
  name                = var.storage_account_name
  zone_name           = "privatelink.file.core.windows.net"
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.storage_account_01_file.private_service_connection[0].private_ip_address]
}