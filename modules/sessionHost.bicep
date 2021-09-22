param name string
param tags object
param location string
param vnetId string
param subnetName string
param localAdminName string
@secure()
param localAdminPassword string
param vmSize string
@allowed([
  'Windows_Client'
  'Windows_Server'
])
param licenseType string = 'Windows_Client'
param domainToJoin string
param domainUserName string
@secure()
param domainPassword string
@description('Set of bit flags that define the join options. Default value of 3 is a combination of NETSETUP_JOIN_DOMAIN (0x00000001) & NETSETUP_ACCT_CREATE (0x00000002) i.e. will join the domain and create the account on the domain. For more information see https://msdn.microsoft.com/en-us/library/aa392154(v=vs.85).aspx')
param domainJoinOptions int = 3
param ouPath string
param installNVidiaGPUDriver bool = false
param hostPoolName string
param hostPoolToken string

resource networkInterface 'Microsoft.Network/networkInterfaces@2019-07-01' = {
  name: 'nic-${name}'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: '${vnetId}/subnets/${subnetName}'
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

resource sessionHost 'Microsoft.Compute/virtualMachines@2019-07-01' = {
  name: 'vm${name}'
  location: location
  tags: tags
  properties: {
    osProfile: {
      computerName: 'vm${name}'
      adminUsername: localAdminName
      adminPassword: localAdminPassword
    }
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'microsoftwindowsdesktop'
        offer: 'office-365'
        sku: '20h2-evd-o365pp'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    licenseType: licenseType
    networkProfile: {
      networkInterfaces: [
        {
          properties: {
            primary: true
          }
          id: networkInterface.id
        }
      ]
    }
  }
}

resource sessionHostDomainJoin 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = {
  name: '${sessionHost.name}/JoinDomain'
  location: location
  tags: tags
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'JsonADDomainExtension'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      name: domainToJoin
      ouPath: ouPath
      user: domainUserName
      restart: true
      options: domainJoinOptions
    }
    protectedSettings: {
      password: domainPassword
    }
  }
}

resource sessionHostAVDAgent 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = {
  name: '${sessionHost.name}/AvdAgentInstall'
  location: location
  tags: tags
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.73'
    autoUpgradeMinorVersion: true
    settings: {
      modulesUrl: 'https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_3-10-2021.zip'
      configurationFunction: 'Configuration.ps1\\AddSessionHost'
      properties: {
        HostPoolName: hostPoolName
      }
    }
    protectedSettings: {
      registrationInfoToken: hostPoolToken
    }
  }
}

resource sessionHostGPUDriver 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = if (installNVidiaGPUDriver) {
  name: '${sessionHost.name}/NvidiaGpuDriverWindows'
  location: location
  tags: tags
  properties: {
    publisher: 'Microsoft.HpcCompute'
    type: 'NvidiaGpuDriverWindows'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {}
  }
}
