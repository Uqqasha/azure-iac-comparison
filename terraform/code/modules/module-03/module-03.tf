data "azurerm_key_vault_secret" "adminpassword" {
  name         = "adminpassword"
  key_vault_id = var.key_vault_id
}

# Database server virtual machine
resource "azurerm_windows_virtual_machine" "vm_mssql_win" {
  name                     = var.vm_mssql_win_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  size                     = var.vm_mssql_win_size
  admin_username           = var.admin_username
  admin_password           = data.azurerm_key_vault_secret.adminpassword.value
  network_interface_ids    = [azurerm_network_interface.vm_mssql_win_nic_01.id]
  enable_automatic_updates = true
  patch_mode               = "AutomaticByOS"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.vm_mssql_win_storage_account_type
  }

  source_image_reference {
    publisher = var.vm_mssql_win_image_publisher
    offer     = var.vm_mssql_win_image_offer
    sku       = var.vm_mssql_win_image_sku
    version   = var.vm_mssql_win_image_version
  }
}

# Nics
resource "azurerm_network_interface" "vm_mssql_win_nic_01" {
  name                = "nic-${var.vm_mssql_win_name}-1"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipc-${var.vm_mssql_win_name}-1"
    subnet_id                     = var.vnet_app_01_subnets["snet-db-01"].id
    private_ip_address_allocation = "Dynamic"
  }
}

# Data disks
resource "azurerm_managed_disk" "vm_mssql_win_data_disks" {
  for_each = var.vm_mssql_win_data_disk_config

  name                 = "disk-${var.vm_mssql_win_name}-${each.value.name}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = var.vm_mssql_win_storage_account_type
  create_option        = "Empty"
  disk_size_gb         = each.value.disk_size_gb
}

resource "azurerm_virtual_machine_data_disk_attachment" "vm_mssql_win_data_disk_attachments" {
  for_each = var.vm_mssql_win_data_disk_config

  managed_disk_id    = azurerm_managed_disk.vm_mssql_win_data_disks[each.key].id
  virtual_machine_id = azurerm_windows_virtual_machine.vm_mssql_win.id
  lun                = each.value.lun
  caching            = each.value.caching
}