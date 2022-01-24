param name string
param tags object
param location string
param aadJoin bool
param count int
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
param rbacObjectId string
param rbacPrincipalType string

// Retrieve the host pool info to pass into the module that builds session hosts. These values will be used when invoking the VM extension to install AVD agents
resource hostPoolToken 'Microsoft.DesktopVirtualization/hostPools@2021-01-14-preview' existing = {
  name: 'hp-${name}'
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2019-07-01' = [for i in range(0, count): {
  name: 'nic-${take(name, 10)}-${i + 1}'
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
}]

resource sessionHost 'Microsoft.Compute/virtualMachines@2019-07-01' = [for i in range(0, count): {
  name: 'vm${take(name, 10)}-${i + 1}'
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    osProfile: {
      computerName: 'vm${take(name, 10)}-${i + 1}'
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
        sku: 'win11-21h2-avd-m365'
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
          id: networkInterface[i].id
        }
      ]
    }
  }

  dependsOn: [
    networkInterface[i]
  ]
}]

// Run this if we are not Azure AD joining the session hosts
resource sessionHostDomainJoin 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = [for i in range(0, count): if (!aadJoin) {
  name: '${sessionHost[i].name}/JoinDomain'
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

  dependsOn: [
    sessionHost[i]
  ]
}]

// Run this if we are Azure AD joining the session hosts - no intune support
resource sessionHostAADLogin 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = [for i in range(0, count): if (aadJoin) {
  name: '${sessionHost[i].name}/AADLoginForWindows'
  location: location
  tags: tags
  properties: {
    publisher: 'Microsoft.Azure.ActiveDirectory'
    type: 'AADLoginForWindows'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
  }
}]

resource sessionHostAVDAgent 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = [for i in range(0, count): {
  name: '${sessionHost[i].name}/AddSessionHost'
  location: location
  tags: tags
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.73'
    autoUpgradeMinorVersion: true
    settings: {
      modulesUrl: 'https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_8-16-2021.zip'
      configurationFunction: 'Configuration.ps1\\AddSessionHost'
      properties: {
        hostPoolName: hostPoolToken.name
        registrationInfoToken: hostPoolToken.properties.registrationInfo.token
        aadJoin: aadJoin
      }
    }
  }

  dependsOn: [
    sessionHostDomainJoin[i]
  ]
}]

resource sessionHostGPUDriver 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = [for i in range(0, count): if (installNVidiaGPUDriver) {
  name: '${sessionHost[i].name}/InstallNvidiaGpuDriverWindows'
  location: location
  tags: tags
  properties: {
    publisher: 'Microsoft.HpcCompute'
    type: 'NvidiaGpuDriverWindows'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {}
  }
}]

// // Assign RBAC permissions to the session hosts - this is only needed if session hosts are AAD join is enabled
// resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = [for i in range(0, count): if (aadJoin) {
//   name: '${sessionHost[i].name}-login'
//   scope: sessionHost[i]
//   properties: {
//     roleDefinitionId: 'fb879df8-f326-4884-b1cf-06f3ad86be52' // Virtual Machine User Login
//     principalId: rbacObjectId
//     principalType: rbacPrincipalType
//   }

//   dependsOn: [
//     sessionHost[i]
//   ]
// }]
