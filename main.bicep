targetScope = 'subscription'

param name string
param location string = deployment().location
param tags object = {
  'availability-level': 'a1'
  'environment': 'prod'
  'mission': 'administrative'
  'po-number': 'zzz'
  'protection-level': 'p1'
}
param vnetAddressPrefix string
param snetAddressPrefix string
param snetName string
param localAdminName string
@secure()
param localAdminPassword string
param vmSize string
param vmCount int

resource resourceGroup 'Microsoft.Resources/resourceGroups@2020-01-01' = {
  name: 'rg-${name}'
  location: location
  scope: subscription()
  tags: tags
}

module networkSecurityGroup 'modules/networkSecurityGroup.bicep' = {
  name: 'networkSecurityGroupDeploy'
  scope: resourceGroup
  params: {
    name: name
    tags: tags
    location: location
  }
}

module virtualNetwork 'modules/virtualNetwork.bicep' = {
  name: 'virtualNetworkDeploy'
  scope: resourceGroup
  params: {
    name: name
    tags: tags
    location: location
    vnetAddressPrefix: vnetAddressPrefix
    snetAddressPrefix: snetAddressPrefix
    snetName: snetName
    networkSecurityGroupId: networkSecurityGroup.outputs.id
  }
}

module hostPool 'modules/hostPools.bicep' = {
  scope: resourceGroup
  name: 'hostPoolDeploy'
  params: {
    name: name
    tags: tags
    location: location
    hostPoolType: 'Pooled'
  }
}

module applicationGroup 'modules/applicationGroup.bicep' = {
  scope: resourceGroup
  name: 'applicationGroupDeploy'
  params: {
    name: name
    tags: tags
    location: location
    hostPoolId: hostPool.outputs.id
  }
}

module workspace 'modules/workspace.bicep' = {
  scope: resourceGroup
  name: 'workspaceDeploy'
  params: {
    name: name
    tags: tags
    location: location
    applicationGroupId: applicationGroup.outputs.id
  }
}

module sessionHost 'modules/sessionHost.bicep' = {
  scope: resourceGroup
  name: 'sessionHostDeploy'
  params: {
    name: name
    tags: tags
    location: location
    count: vmCount
    localAdminName: localAdminName
    localAdminPassword: localAdminPassword
    subnetName: snetName
    vmSize: vmSize
    vnetId: virtualNetwork.outputs.id
  }

  dependsOn: [
    hostPool
  ]
}
