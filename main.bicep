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
param hubVnetName string
param hubVnetRGName string
param hubVnetSubId string
param dnsServer string
param localAdminName string
@secure()
param localAdminPassword string
param vmSize string
param licenseType string
param domainToJoin string
param domainUserName string
@secure()
param domainPassword string
param ouPath string

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
    dnsServer: dnsServer
    networkSecurityGroupId: networkSecurityGroup.outputs.id
  }
}

// Creates a VNET peering from the hub virtual network to the AVD VNET
module virtualNetworkPeering1 'modules/virtualNetworkPeering.bicep' = {
  name: 'vnetPeeringDeploy1'
  scope: az.resourceGroup(resourceGroup.name)
  params: {
    remoteVnetName: virtualNetwork.outputs.name
    remoteVnetRsourceGroupName: resourceGroup.name
    remoteVnetSubscriptionId: subscription().id
    vnetName: hubVnetName
    vnetRsourceGroupName: hubVnetRGName
  }

  dependsOn: [
    resourceGroup
  ]
}

// Creates a VNET peering from the AVD VNET to the hub virtual network
module virtualNetworkPeering2 'modules/virtualNetworkPeering.bicep' = {
  name: 'vnetPeeringDeploy2'
  scope: az.resourceGroup(hubVnetRGName)
  params: {
    remoteVnetName: hubVnetName
    remoteVnetRsourceGroupName: hubVnetRGName
    remoteVnetSubscriptionId: hubVnetSubId
    vnetName: virtualNetwork.outputs.name
    vnetRsourceGroupName: resourceGroup.name
  }

  dependsOn: [
    resourceGroup
  ]
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
    count: 2
    localAdminName: localAdminName
    localAdminPassword: localAdminPassword
    subnetName: snetName
    vmSize: vmSize
    licenseType: licenseType
    domainToJoin: domainToJoin
    domainPassword: domainPassword
    domainUserName: domainUserName
    ouPath: ouPath
    vnetId: virtualNetwork.outputs.id
  }

  dependsOn: [
    virtualNetworkPeering1
    virtualNetworkPeering2
    hostPool
  ]
}
