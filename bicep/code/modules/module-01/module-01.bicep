param location string
param ownerObjectId string
param armClientObjectId string
param adminUsername string
param vnetDnsServers array

param storageAccountSKU string = 'Standard_LRS'
param storageAccountKind string = 'StorageV2'
param storageContainerName string = 'scripts'

param logAnalyticsWorkspaceName string = 'log-shared-bicep-01'
param logAnalyticsWorkspaceSKU string = 'PerGB2018'
param logAnalyticsWorkspaceRetentionDays int = 30

param keyVaultSKU string = 'Standard'
param automationAccountSku string = 'Basic'

param vnetName string = 'vnet-shared-01'
param vnetAddressPrefix string = '10.1.0.0/16'

param bastionName string = 'bst-bicep-01'
param bastionPipSKU string = 'Standard'
param bastionPipAllocation string = 'Static'

param vmAddsName string = 'adds1'
param vmAddsNicPrivateIpAllocationMethod string = 'Dynamic'
param vmAddsSize string = 'Standard_B1s'
param vmAddsImagePublisher string = 'MicrosoftWindowsServer'
param vmAddsImageOffer string = 'WindowsServer'
param vmAddsImageSku string = '2022-datacenter-core-g2'
param vmAddsImageVersion string = 'Latest'
param vmAddsStorageAccountCaching string = 'ReadWrite'
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
    dhcpOptions: {
      dnsServers: vnetDnsServers
    }
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

resource bastionPip 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: 'pip-${bastionName}'
  location: location
  sku: {
    name: bastionPipSKU
  }
  properties: {
    publicIPAllocationMethod: bastionPipAllocation
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2023-09-01' = {
  name: bastionName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipc-${bastionName}'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, 'AzureBastionSubnet')
          }
          publicIPAddress: {
            id: bastionPip.id
          }
        }
      }
    ]
  }
  dependsOn: [ vnet ]
}

resource vmAddsNic 'Microsoft.Network/networkInterfaces@2022-05-01' = {
  name: 'nic-${vmAddsName}-1'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipc-${vmAddsName}-1'
        properties: {
          privateIPAllocationMethod: vmAddsNicPrivateIpAllocationMethod
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, 'snet-adds-01')
          }
        }
      }
    ]
  }
  dependsOn: [ vnet ]
}

resource vmAdds 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: vmAddsName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmAddsSize
    }
    osProfile: {
      computerName: vmAddsName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
        }
      }
    }
    storageProfile: {
      imageReference: {
        publisher: vmAddsImagePublisher
        offer: vmAddsImageOffer
        sku: vmAddsImageSku
        version: vmAddsImageVersion
      }
      osDisk: {
        createOption: 'FromImage'
        caching: vmAddsStorageAccountCaching
        managedDisk: {
          storageAccountType: vmAddsStorageAccountType
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmAddsNic.id
        }
      ]
    }
  }
}

@description('The details of subnets and NSGs.')
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
