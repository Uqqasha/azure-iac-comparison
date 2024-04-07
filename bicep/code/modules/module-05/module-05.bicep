param location string
param adminUsername string
@secure()
param adminPassword string
param vnetNameM2 string

param msSqlServerName string = 'mssql-${uniqueString(resourceGroup().id)}'
param msSqlDatabaseName string = 'testdb'

resource msSqlServer 'Microsoft.Sql/servers@2021-11-01' = {
  name: msSqlServerName
  location: location
  properties: {
    administratorLogin: adminUsername
    administratorLoginPassword: adminPassword
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
  }

  resource msSqlServerDatabase 'databases' = {
    name: msSqlDatabaseName
    location: location
    properties: {
      licenseType: 'LicenseIncluded'
    }
  }
}

resource msSqlServerPend 'Microsoft.Network/privateEndpoints@2023-04-01' = {
  name: 'pend-${msSqlServerName}'
  location: location
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetNameM2, 'snet-privatelink-01')
    }
    privateLinkServiceConnections: [
      {
        name: 'azure_sql_database_logical_server'
        properties: {
          privateLinkServiceId: msSqlServer.id
          groupIds: ['sqlServer']
        }
      }
    ]
  }
}

resource privateDnsZoneARecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: 'privatelink.mysql.database.azure.com/${msSqlServerName}'
  properties: {
    ttl: 300
    aRecords: [
      {
        ipv4Address: first(first(msSqlServerPend.properties.customDnsConfigs).ipAddresses)
      }
    ]
  }
}
