param location string
param adminUsername string
@secure()
param adminPassword string
param vnetNameM2 string

param mySqlFlexibleServerName string = 'mysql-${uniqueString(resourceGroup().id)}'
param mySqlFlexibleServerSkuName string = 'Standard_B1s'
param mySqlFlexibleServerSkuTier string = 'Burstable'
param mySqlFlexibleServerZone string = '1'
param mySqlDatabaseName string = 'testdb'

resource mySqlFlexibleServer 'Microsoft.DBforMySQL/flexibleServers@2023-06-30' = {
  name: mySqlFlexibleServerName
  location: location
  sku: {
    name: mySqlFlexibleServerSkuName
    tier: mySqlFlexibleServerSkuTier
  }
  properties: {
    administratorLogin: adminUsername
    administratorLoginPassword: adminPassword
    availabilityZone: mySqlFlexibleServerZone
  }

  resource mySqlFlexibleDatabase 'databases' = {
    name: mySqlDatabaseName
    properties: {
      charset: 'utf8'
      collation: 'utf8_unicode_ci'
    }
  }
}

resource mySqlFlexibleServerPend 'Microsoft.Network/privateEndpoints@2023-04-01' = {
  name: 'pend-${mySqlFlexibleServerName}'
  location: location
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetNameM2, 'snet-privatelink-01')
    }
    privateLinkServiceConnections: [
      {
        name: 'azure_mysql_flexible_server'
        properties: {
          privateLinkServiceId: mySqlFlexibleServer.id
          groupIds: ['mysqlServer']
        }
      }
    ]
  }
}

resource privateDnsZoneARecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: 'privatelink.mysql.database.azure.com/${mySqlFlexibleServerName}'
  properties: {
    ttl: 300
    aRecords: [
      {
        ipv4Address: first(first(mySqlFlexibleServerPend.properties.customDnsConfigs).ipAddresses)
      }
    ]
  }
}
