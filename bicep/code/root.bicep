@description('The name of the Azure Region where resources will be provisioned.')
param location string = resourceGroup().location

@description('The Object ID of Azure CLI signed in User.')
param ownerObjectId string

@description('The Object ID for the service principal.')
param armClientObjectId string

@description('')
param dnsServers array

@description('Username of admin user.')
param adminUsername string

module module01 'modules/module-01/module-01.bicep' = {
  name: 'module01Deployment'
  params: {
    location: location
    adminUsername: adminUsername
    ownerObjectId: ownerObjectId
    armClientObjectId: armClientObjectId
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: module01.outputs.keyVaultName
}

module module02 'modules/module-02/module-02.bicep' = {
  name: 'module02Deployment'
  params: {
    location: location
    dnsServers: dnsServers
    vnetNameM1: module01.outputs.vnetNameM1
    adminUsername: adminUsername
    adminPassword: keyVault.getSecret('adminpassword')
    storageAccountName: module01.outputs.storageAccountName
    keyVaultName: module01.outputs.keyVaultName
  }
  dependsOn: [
    module01
  ]
}
