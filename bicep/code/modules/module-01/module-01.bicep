@description('The name of the Azure Region where resources will be provisioned.')
param location string

@description('Defines the Tier to use for this storage account.')
param storageAccountSKU string = 'Standard_LRS'

@description('Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2.')
param storageAccountKind string = 'StorageV2'

@description('The name of the Container which should be created within the Storage Account.')
param storageContainerName string = 'scripts'

@description('The name of the new Log Analytics Workspace to be provisioned.')
param logAnalyticsWorkspaceName string = 'log-shared-bicep-01'

@description('Specifies the SKU of the Log Analytics Workspace. Possible values are Free, PerNode, Premium, Standard, Standalone, Unlimited, CapacityReservation, and PerGB2018.')
param logAnalyticsWorkspaceSKU string = 'PerGB2018'

@description('The workspace data retention in days.')
param logAnalyticsWorkspaceRetentionDays int = 30

@description('The Name of the SKU used for this Key Vault. Possible values are standard and premium.')
param keyVaultSKU string = 'Standard'

@description('The Object ID of Azure CLI signed in User.')
param ownerObjectId string

@description('The Object ID for the service principal.')
param armClientObjectId string

@description('Username of admin user.')
param adminUsername string

@description('The automation account SKU. Basic or Free.')
param automationAccountSku string = 'Basic'

@description('The name of the new virtual network to be provisioned.')
param vnetName string = 'vnet-shared-01'

@description('The address space in CIDR notation for the new virtual network.')
param vnetAddressPrefix string = '10.1.0.0/16'

@description('The name of Bastion Host.')
param bastionName string = 'bst-bicep-01'

@description('The SKU of the Public IP. Accepted values are Basic and Standard.')
param bastionPipSKU string = 'Standard'

@description('Defines the allocation method for this IP address. Possible values are Static or Dynamic.')
param bastionPipAllocation string = 'Static'

@description('The name of the VM.')
param vmAddsName string = 'adds1'

@description('The private IP address allocation method.')
param vmAddsNicPrivateIpAllocationMethod string = 'Dynamic'

@description('The size of the virtual machine.')
param vmAddsSize string = 'Standard_B2s'

@description('The publisher for the virtual machine image used to create the VM.')
param vmAddsImagePublisher string = 'MicrosoftWindowsServer'

@description('The offer type of the virtual machine image used to create the VM.')
param vmAddsImageOffer string = 'WindowsServer'

@description('The sku of the virtual machine image used to create the VM.')
param vmAddsImageSku string = '2022-datacenter-core-g2'

@description('The version of the virtual machine image used to create the VM.')
param vmAddsImageVersion string = 'Latest'

@description('The storage replication type to be used for the VMs OS and data disks.')
param vmAddsStorageAccountCaching string = 'ReadWrite'

@description('The storage replication type to be used for the VMs OS and data disks.')
param vmAddsStorageAccountType string = 'Standard_LRS'

var adminPassword = 'P-${uniqueString(resourceGroup().id, deployment().name)}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'st${uniqueString(resourceGroup().id)}'
  location: location
  sku: {
    name: storageAccountSKU
  }
  kind: storageAccountKind

  resource stBlob 'blobServices@2023-01-01' = {
    name: 'default'
    resource stContainer 'containers@2023-01-01' = {
      name: storageContainerName
    }
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    sku: {
      name: logAnalyticsWorkspaceSKU
    }
    retentionInDays: logAnalyticsWorkspaceRetentionDays
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: 'kv-${uniqueString(resourceGroup().id)}'
  location: location
  properties: {
    enableSoftDelete: false
    softDeleteRetentionInDays: 7
    enabledForTemplateDeployment: true
    tenantId: subscription().tenantId
    sku: {
      name: keyVaultSKU
      family: 'A'
    }
    accessPolicies: [
      {
        objectId: ownerObjectId
        tenantId: subscription().tenantId
        permissions: {
          secrets: ['Get', 'List', 'Set', 'Delete', 'Purge']
        }
      }
      {
        objectId: armClientObjectId
        tenantId: subscription().tenantId
        permissions: {
          secrets: ['Get', 'Set', 'Delete', 'Purge']
        }
      }
    ]
  }
  resource adminUsernameSecret 'secrets@2023-07-01' = {
    name: 'adminuser'
    properties: {
      value: adminUsername
    }
  }
  resource adminPasswordSecret 'secrets@2023-07-01' = {
    name: 'adminpassword'
    properties: {
      value: adminPassword
    }
  }
  resource storageAccountKey 'secrets@2023-07-01' = {
    name: storageAccount.name
    properties: {
      value: storageAccount.listKeys().keys[0].value
    }
  }
  resource logAnalyticsWorkspaceKey 'secrets@2023-07-01' = {
    name: '${logAnalyticsWorkspace.name}-ID'
    properties: {
      value: logAnalyticsWorkspace.listKeys().primarySharedKey
    }
  }
}

// resource automationAccount 'Microsoft.Automation/automationAccounts@2023-11-01' = {
//   name: 'auto-${uniqueString(resourceGroup().id)}-01'
//   location: location
//   properties: {
//     sku: {
//       name: automationAccountSku
//     }
//   }
// }

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [ for subnet in items(subnets): {
      name: subnet.key
      properties: {
        addressPrefix: subnet.value.addressPrefix
        privateEndpointNetworkPolicies: subnet.value.privateEndpointNetworkPolicies
        networkSecurityGroup: { id: resourceId('Microsoft.Network/networkSecurityGroups', 'nsg-${vnetName}.${subnet.key}')}
      }
    }]
  }
  dependsOn: [ nsg ]
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = [ for nsg in items(subnets): {
  name: 'nsg-${vnetName}.${nsg.key}'
  location: location
  properties: {
    securityRules: nsg.value.securityRules
  }
}]

// resource bastionPip 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
//   name: 'pip-${bastionName}'
//   location: location
//   sku: {
//     name: bastionPipSKU
//   }
//   properties: {
//     publicIPAllocationMethod: bastionPipAllocation
//   }
// }

// resource bastionHost 'Microsoft.Network/bastionHosts@2023-09-01' = {
//   name: bastionName
//   location: location
//   properties: {
//     ipConfigurations: [
//       {
//         name: 'ipc-${bastionName}'
//         properties: {
//           subnet: {
//             id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, 'AzureBastionSubnet')
//           }
//           publicIPAddress: {
//             id: bastionPip.id
//           }
//         }
//       }
//     ]
//   }
//   dependsOn: [ vnet ]
// }

// resource vmAddsNic 'Microsoft.Network/networkInterfaces@2022-05-01' = {
//   name: 'nic-${vmAddsName}-1'
//   location: location
//   properties: {
//     ipConfigurations: [
//       {
//         name: 'ipc-${vmAddsName}-1'
//         properties: {
//           privateIPAllocationMethod: vmAddsNicPrivateIpAllocationMethod
//           subnet: {
//             id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, 'snet-adds-01')
//           }
//         }
//       }
//     ]
//   }
//   dependsOn: [ vnet ]
// }

// resource vmAdds 'Microsoft.Compute/virtualMachines@2022-03-01' = {
//   name: vmAddsName
//   location: location
//   properties: {
//     hardwareProfile: {
//       vmSize: vmAddsSize
//     }
//     osProfile: {
//       computerName: vmAddsName
//       adminUsername: adminUsername
//       adminPassword: adminPassword
//       windowsConfiguration: {
//         enableAutomaticUpdates: false
//         patchSettings: {
//           patchMode: 'Manual'
//         }
//       }
//     }
//     storageProfile: {
//       imageReference: {
//         publisher: vmAddsImagePublisher
//         offer: vmAddsImageOffer
//         sku: vmAddsImageSku
//         version: vmAddsImageVersion
//       }
//       osDisk: {
//         createOption: 'FromImage'
//         caching: vmAddsStorageAccountCaching
//         managedDisk: {
//           storageAccountType: vmAddsStorageAccountType
//         }
//       }
//     }
//     networkProfile: {
//       networkInterfaces: [
//         {
//           id: vmAddsNic.id
//         }
//       ]
//     }
//   }
// }

@description('The name of the new virtual network to be provisioned.')
param subnets object = {
  AzureBastionSubnet: {
    addressPrefix: '10.1.0.0/27'
    privateEndpointNetworkPolicies: 'Disabled'
    securityRules: [
      {
        name: 'AllowHttpsInbound'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: '*'
          destinationPortRange: ''
          destinationPortRanges: ['443']
          direction: 'Inbound'
          priority: '100'
          protocol: 'Tcp'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowGatewayManagerInbound'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: '*'
          destinationPortRange: ''
          destinationPortRanges: ['443']
          direction: 'Inbound'
          priority: '110'
          protocol: 'Tcp'
          sourceAddressPrefix: 'GatewayManager'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowAzureLoadBalancerInbound'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: '*'
          destinationPortRange: ''
          destinationPortRanges: ['443']
          direction: 'Inbound'
          priority: '120'
          protocol: 'Tcp'
          sourceAddressPrefix: 'AzureLoadBalancer'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowBastionCommunicationInbound'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: '*'
          destinationPortRange: ''
          destinationPortRanges: ['8080', '5701']
          direction: 'Inbound'
          priority: '130'
          protocol: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowSshRdpOutbound'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: ''
          destinationPortRanges: ['22', '3389']
          direction: 'Outbound'
          priority: '140'
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowAzureCloudOutbound'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: 'AzureCloud'
          destinationPortRange: ''
          destinationPortRanges: ['443']
          direction: 'Outbound'
          priority: '150'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowBastionCommunicationOutbound'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: ''
          destinationPortRanges: ['8080', '5701']
          direction: 'Outbound'
          priority: '160'
          protocol: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowGetSessionInformationOutbound'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: 'Internet'
          destinationPortRange: ''
          destinationPortRanges: ['80']
          direction: 'Outbound'
          priority: '170'
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
    ]
  }
  'snet-adds-01': {
    addressPrefix: '10.1.1.0/24'
    privateEndpointNetworkPolicies: 'Disabled'
    securityRules: [
      {
        name: 'AllowVirtualNetworkInbound'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '*'
          destinationPortRanges: []
          direction: 'Inbound'
          priority: '100'
          protocol: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowVirtualNetworkOutbound'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '*'
          destinationPortRanges: []
          direction: 'Outbound'
          priority: '110'
          protocol: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowInternetOutbound'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: 'Internet'
          destinationPortRange: '*'
          destinationPortRanges: []
          direction: 'Outbound'
          priority: '120'
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
    ]
  }
  'snet-misc-01': {
    addressPrefix: '10.1.2.0/24'
    privateEndpointNetworkPolicies: 'Disabled'
    securityRules: [
      {
        name: 'AllowVirtualNetworkInbound'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '*'
          destinationPortRanges: []
          direction: 'Inbound'
          priority: '100'
          protocol: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowVirtualNetworkOutbound'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '*'
          destinationPortRanges: []
          direction: 'Outbound'
          priority: '110'
          protocol: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowInternetOutbound'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: 'Internet'
          destinationPortRange: '*'
          destinationPortRanges: []
          direction: 'Outbound'
          priority: '120'
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
    ]
  }
  'snet-misc-02': {
    addressPrefix: '10.1.3.0/24'
    privateEndpointNetworkPolicies: 'Disabled'
    securityRules: [
      {
        name: 'AllowVirtualNetworkInbound'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '*'
          destinationPortRanges: []
          direction: 'Inbound'
          priority: '100'
          protocol: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowVirtualNetworkOutbound'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '*'
          destinationPortRanges: []
          direction: 'Outbound'
          priority: '110'
          protocol: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowInternetOutbound'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: 'Internet'
          destinationPortRange: '*'
          destinationPortRanges: []
          direction: 'Outbound'
          priority: '120'
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
    ]
  }
}

output vnetNameM1 string = vnet.name
output storageAccountName string = storageAccount.name
output keyVaultName string = keyVault.name
