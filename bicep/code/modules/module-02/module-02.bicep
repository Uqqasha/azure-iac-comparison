param location string
param dnsServers array
param vnetNameM1 string
param adminUsername string
@secure()
param adminPassword string 
param keyVaultName string
param storageAccountName string

param vnetNameM2 string = 'vnet-app-01'
param vnetAddressPrefixM2 string = '10.2.0.0/16'

param privateDnsZones array = [ 'privatelink.database.windows.net', 'privatelink.file.core.windows.net', 'privatelink.mysql.database.azure.com']

param vmJumpboxWinName string = 'jumpwin1'
param vmJumpboxWinSize string = 'Standard_B1s'
param vmJumpboxWinPublisher string = 'MicrosoftWindowsServer'
param vmJumpboxWinOffer string = 'WindowsServer'
param vmJumpboxWinSku string = '2022-datacenter-g2'
param vmJumpboxWinVersion string = 'Latest'
param vmJumpboxWinStorageAccountType string = 'Standard_LRS'

param vmJumpboxLinuxName string = 'jumplinux1'
param vmJumpboxLinuxSize string = 'Standard_B1s'
param vmJumpboxLinuxPublisher string = 'Canonical'
param vmJumpboxLinuxOffer string = '0001-com-ubuntu-server-jammy'
param vmJumpboxLinuxSku string = '22_04-lts-gen2'
param vmJumpboxLinuxVersion string = 'Latest'
param vmJumpboxLinuxStorageAccountType string = 'Standard_LRS'

param storageShareName string = 'myfileshare'
param storageShareQuota int = 1024

resource vnetApp 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetNameM2
  location: location
  properties: {
    dhcpOptions: {
      dnsServers: dnsServers
    }
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefixM2
      ]
    }
    subnets: [ for (subnet, i) in items(subnets): {
      name: subnet.key
      properties: {
        addressPrefix: subnet.value.addressPrefix
        privateEndpointNetworkPolicies: subnet.value.privateEndpointNetworkPolicies
        networkSecurityGroup: { id: nsg[i].id}
      }
    }]
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = [ for nsg in items(subnets): {
  name: 'nsg-${vnetNameM2}.${nsg.key}'
  location: location
  properties: {
    securityRules: nsg.value.securityRules
  }
}]

resource vnetApp01tovnetShared01Peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-04-01' = {
  name: 'vnet_app_01_to_vnet_shared_01_peering'
  parent: vnetApp
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    remoteVirtualNetwork: {
      id: resourceId('Microsoft.Network/virtualNetworks', vnetNameM1)
    }
  }
}

resource vnetShared01tovnetApp01Peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-04-01' = {
  name: '${vnetNameM1}/vnet_shared_01_to_vnet_app_01_peering'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    remoteVirtualNetwork: {
      id: vnetApp.id
    }
  }
}

resource privateDNSZones 'Microsoft.Network/privateDnsZones@2020-06-01' = [ for privateDnsZone in privateDnsZones: {
  name: privateDnsZone
  location: 'global'
}]

resource privateDNSZoneVirtualNetworkLinksVnetApp01 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [ for (privateDnsZone, i) in privateDnsZones: {
  name: 'pdsnlink-${privateDnsZone}-${vnetApp.name}'
  parent: privateDNSZones[i]
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetApp.id
    }
  }
  dependsOn: [
    vnetApp01tovnetShared01Peering, vnetApp01tovnetShared01Peering
  ]
}]

resource privateDNSZoneVirtualNetworkLinksVnetShared01 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [ for (privateDnsZone, i) in privateDnsZones: {
  name: 'pdsnlink-${privateDnsZone}-${vnetNameM1}'
  parent: privateDNSZones[i]
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: resourceId('Microsoft.Network/virtualNetworks', vnetNameM1)
    }
  }
  dependsOn: [
    vnetApp01tovnetShared01Peering, vnetApp01tovnetShared01Peering
  ]
}]

// resource vmJumpboxWinNic 'Microsoft.Network/networkInterfaces@2022-05-01' = {
//   name: 'nic-${vmJumpboxWinName}-1'
//   location: location
//   properties: {
//     ipConfigurations: [
//       {
//         name: 'ipc-${vmJumpboxWinName}-1'
//         properties: {
//           privateIPAllocationMethod: 'Dynamic'
//           subnet: {
//             id: vnetApp.properties.subnets[0].id
//           }
//         }
//       }
//     ]
//   }
// }

// resource vmJumpboxWin 'Microsoft.Compute/virtualMachines@2022-03-01' = {
//   name: vmJumpboxWinName
//   location: location
//   properties: {
//     hardwareProfile: {
//       vmSize: vmJumpboxWinSize
//     }
//     osProfile: {
//       computerName: vmJumpboxWinName
//       adminUsername: adminUsername
//       adminPassword: adminPassword
//       windowsConfiguration: {
//         enableAutomaticUpdates: true
//         patchSettings: {
//           patchMode: 'AutomaticByOS'
//         }
//       }
//     }
//     storageProfile: {
//       imageReference: {
//         publisher: vmJumpboxWinPublisher
//         offer: vmJumpboxWinOffer
//         sku: vmJumpboxWinSku
//         version: vmJumpboxWinVersion
//       }
//       osDisk: {
//         createOption: 'FromImage'
//         caching: 'ReadWrite'
//         managedDisk: {
//           storageAccountType: vmJumpboxWinStorageAccountType
//         }
//       }
//     }
//     networkProfile: {
//       networkInterfaces: [
//         {
//           id: vmJumpboxWinNic.id
//         }
//       ]
//     }
//   }
// }

resource vmJumpboxLinuxNic 'Microsoft.Network/networkInterfaces@2022-05-01' = {
  name: 'nic-${vmJumpboxLinuxName}-1'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipc-${vmJumpboxLinuxName}-1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnetApp.properties.subnets[0].id
          }
        }
      }
    ]
  }
}

resource vmJumpboxLinux 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: vmJumpboxLinuxName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmJumpboxLinuxSize
    }
    osProfile: {
      computerName: vmJumpboxLinuxName
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
      }
    }
    storageProfile: {
      imageReference: {
        publisher: vmJumpboxLinuxPublisher
        offer: vmJumpboxLinuxOffer
        sku: vmJumpboxLinuxSku
        version: vmJumpboxLinuxVersion
      }
      osDisk: {
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: vmJumpboxLinuxStorageAccountType
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmJumpboxLinuxNic.id
        }
      ]
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource vmJumpboxLinuxSecretsGet 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  name: '${keyVaultName}/add'
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: vmJumpboxLinux.identity.principalId
        permissions: {
          secrets: ['get']
        }
      }
    ]
  }
}

resource storageShare01 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = {
  name: '${storageAccountName}/default/${storageShareName}'
  properties: {
    shareQuota: storageShareQuota
  }
}

resource storageAccount01File 'Microsoft.Network/privateEndpoints@2023-04-01' = {
  name: 'pend-${storageAccountName}-file'
  location: location
  properties: {
    subnet: {
      id: vnetApp.properties.subnets[3].id
    }
    privateLinkServiceConnections: [
      {
        name: 'azure_files'
        properties: {
          privateLinkServiceId: resourceId('Microsoft.Storage/storageAccounts', storageAccountName)
          groupIds: ['file']
        }
      }
    ]
  }
}

resource privateDnsZoneARecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: 'privatelink.file.core.windows.net/${storageAccountName}'
  properties: {
    ttl: 300
    aRecords: [
      {
        ipv4Address: first(first(storageAccount01File.properties.customDnsConfigs).ipAddresses)
      }
    ]
  }
  dependsOn: [privateDNSZones]
}

@description('The details of subnets and NSGs.')
param subnets object = {
  'snet-app-01': {
    addressPrefix: '10.2.0.0/24'
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
  'snet-db-01': {
    addressPrefix: '10.2.1.0/24'
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
  'snet-misc-03': {
    addressPrefix: '10.2.3.0/24'
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
  'snet-privatelink-01': {
    addressPrefix: '10.2.2.0/24'
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

output vnetNameM2 string = vnetApp.name
