variable "aad_tenant_id" {
  type        = string
}
variable "subscription_id" {
  type        = string
}
variable "arm_client_id" {
  type        = string
}
variable "arm_client_secret" {
  type        = string
  sensitive   = true
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