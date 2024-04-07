param location string
param adminUsername string
@secure()
param adminPassword string
param vnetNameM2 string

param vmMssqlWinName string = 'mssqlwin1'
param vmMssqlWinSize string = 'Standard_B1s'
param vmMssqlWinPublisher string = 'MicrosoftSQLServer'
param vmMssqlWinOffer string = 'sql2022-ws2022'
param vmMssqlWinSku string = 'sqldev-gen2'
param vmMssqlWinVersion string = 'Latest'
param vmMssqlWinStorageAccountType string = 'StandardSSD_LRS'
param vmMssqlWinDataDiskConfig object = {
  vol_sqldata_M: {
    diskSize: '128'
    lun: '0'
    caching: 'ReadOnly'
  }
  vol_sqllog_L: {
    diskSize: '32'
    lun: '1'
    caching: 'None'
  }
}

resource vmMssqlWinNic 'Microsoft.Network/networkInterfaces@2022-05-01' = {
  name: 'nic-${vmMssqlWinName}-1'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipc-${vmMssqlWinName}-1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetNameM2, 'snet-app-01')
          }
        }
      }
    ]
  }
}

resource vmMssqlWin 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: vmMssqlWinName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmMssqlWinSize
    }
    osProfile: {
      computerName: vmMssqlWinName
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
        publisher: vmMssqlWinPublisher
        offer: vmMssqlWinOffer
        sku: vmMssqlWinSku
        version: vmMssqlWinVersion
      }
      osDisk: {
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: vmMssqlWinStorageAccountType
        }
      }
      dataDisks: [for (disk, i) in items(vmMssqlWinDataDiskConfig): {
        lun: disk.value.lun
        caching: disk.value.caching
        createOption: 'Attach'
        managedDisk: {
          id: vmMssqlWinDisks[i].id
        }
      }]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmMssqlWinNic.id
        }
      ]
    }
  }
}

resource vmMssqlWinDisks 'Microsoft.Compute/disks@2023-10-02' = [for disk in items(vmMssqlWinDataDiskConfig): {
  name: 'disk-${vmMssqlWinName}-${disk.key}'
  location: location
  sku: {
    name: vmMssqlWinStorageAccountType
  }
  properties: {
    creationData: {
      createOption: 'Empty'
    }
    diskSizeGB: disk.value.diskSize
  }
}]
