output "vnet_shared_01_name" {
  value = azurerm_virtual_network.vnet_shared_01.name
}
output "vnet_shared_01_id" {
  value = azurerm_virtual_network.vnet_shared_01.id
}
output "key_vault_id" {
  value = azurerm_key_vault.kv.id
}
output "storage_account_name" {
  value = azurerm_storage_account.st.name
}