module "module-01" {
  source = "./modules/module-01"

  resource_group_name  = var.resource_group_name
  location             = var.location
  aad_tenant_id        = var.aad_tenant_id
  owner_object_id      = var.owner_object_id
  arm_client_object_id = var.arm_client_object_id
  admin_username       = var.admin_username
  vnet_dns_servers     = var.vnet_dns_servers
}

# module "module-02" {
#   source = "./modules/module-02"

#   resource_group_name  = var.resource_group_name
#   location             = var.location
#   subscription_id      = var.subscription_id
#   vnet_name_m1         = module.module-01.vnet_shared_01_name
#   vnet_id_m1           = module.module-01.vnet_shared_01_id
#   admin_username       = var.admin_username
#   key_vault_id         = module.module-01.key_vault_id
#   storage_account_name = module.module-01.storage_account_name
#   vnet_dns_servers     = var.vnet_dns_servers

#   depends_on = [ module.module-01 ]
# }

# module "module-03" {
#   source = "./modules/module-03"

#   resource_group_name  = var.resource_group_name
#   location             = var.location
#   admin_username       = var.admin_username
#   key_vault_id         = module.module-01.key_vault_id
#   vnet_app_01_subnets  = module.module-02.vnet_app_01_subnets

#   depends_on = [ module.module-01, module.module-02 ]
# }

# module "module-04" {
#   source = "./modules/module-04"

#   resource_group_name  = var.resource_group_name
#   location             = var.location
#   admin_username       = var.admin_username
#   key_vault_id         = module.module-01.key_vault_id
#   vnet_app_01_subnets  = module.module-02.vnet_app_01_subnets

#   depends_on = [ module.module-01, module.module-02 ]
# }

# module "module-05" {
#   source = "./modules/module-05"

#   resource_group_name  = var.resource_group_name
#   location             = var.location
#   admin_username       = var.admin_username
#   key_vault_id         = module.module-01.key_vault_id
#   vnet_app_01_subnets  = module.module-02.vnet_app_01_subnets

#   depends_on = [ module.module-01, module.module-02 ]
# }