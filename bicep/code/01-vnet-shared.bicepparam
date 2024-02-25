using '01-vnet-shared.bicep'

param storageAccountSKU = 'Standard_LRS'
param storageAccountKind = 'StorageV2'
param storageContainerName = 'scripts'

param logAnalyticsWorkspaceName = 'log-shared-bicep-01'
param logAnalyticsWorkspaceSKU = 'PerGB2018'
param logAnalyticsWorkspaceRetentionDays = 30

param keyVaultSKU = 'Standard'
param adminUsername = 'bootstrapadmin'

param automationAccountSku = 'Basic'

param bastionName = 'bst-bicep-01'
param bastionPipSKU = 'Standard'
param bastionPipAllocation = 'Static'

param vmAddsName = 'adds1'
param vmAddsSize = 'Standard_B2s'
param vmAddsNicPrivateIpAllocationMethod = 'Dynamic'
param vmAddsImagePublisher = 'MicrosoftWindowsServer'
param vmAddsImageOffer = 'WindowsServer'
param vmAddsImageSku = '2022-datacenter-core-g2'
param vmAddsImageVersion = 'Latest'
param vmAddsStorageAccountCaching = 'ReadWrite'
param vmAddsStorageAccountType = 'Standard_LRS'

param vnetName = 'vnet-shared-01'
param vnetAddressPrefix = '10.1.0.0/16'
param subnets = {
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
