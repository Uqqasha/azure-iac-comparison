param location string = resourceGroup().location
param ownerObjectId string
param armClientObjectId string
param dnsServers array
param adminUsername string

module module01 'modules/module-01/module-01.bicep' = {
  name: 'module01Deployment'
  params: {
    location: location
    adminUsername: adminUsername
    ownerObjectId: ownerObjectId
    armClientObjectId: armClientObjectId
    vnetDnsServers: dnsServers
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

module module03 'modules/module-03/module-03.bicep' = {
  name: 'module03Deployment'
  params: {
    location: location
    vnetNameM2: module02.outputs.vnetNameM2
    adminUsername: adminUsername
    adminPassword: keyVault.getSecret('adminpassword')
  }
  dependsOn: [
    module01
  ]
}

module module04 'modules/module-04/module-04.bicep' = {
  name: 'module04Deployment'
  params: {
    location: location
    vnetNameM2: module02.outputs.vnetNameM2
    adminUsername: adminUsername
    adminPassword: keyVault.getSecret('adminpassword')
  }
  dependsOn: [
    module01
  ]
}

// module module05 'modules/module-05/module-05.bicep' = {
//   name: 'module05Deployment'
//   params: {
//     location: location
//     vnetNameM2: module02.outputs.vnetNameM2
//     adminUsername: adminUsername
//     adminPassword: keyVault.getSecret('adminpassword')
//   }
//   dependsOn: [
//     module01
//   ]
// }
