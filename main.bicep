targetScope = 'subscription'

param name string
param location string = deployment().location
param tags object
param aadJoin bool
param vnetAddressPrefix string
param snetAddressPrefix string
param localAdminName string
@secure()
param localAdminPassword string
param maxSessionLimit int = 999999
param vmSize string
param vmCount int = 1
param vmLicenseType string
param hubVnetName string = ''
param hubVnetRgName string = ''
param dnsServer string = ''
param domainToJoin string = ''
param domainUserName string = ''
@secure()
param domainPassword string = ''
param ouPath string = ''

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
    snetName: 'sn-${name}'
    dnsServer: (aadJoin ? '' : dnsServer)
    networkSecurityGroupId: networkSecurityGroup.outputs.id
  }
}

// Creates a VNET peering from the hub virtual network to the AVD VNET if we are AD domain joining the session hosts
// No need for this to run if we are not AD domain joining
module virtualNetworkPeering1 'modules/virtualNetworkPeering.bicep' = if (!aadJoin) {
  name: 'vnetPeeringDeploy1'
  scope: az.resourceGroup(resourceGroup.name)
  params: {
    remoteVnetName: virtualNetwork.outputs.name
    remoteVnetRsourceGroupName: resourceGroup.name
    remoteVnetSubscriptionId: subscription().id
    vnetName: hubVnetName
    vnetRsourceGroupName: hubVnetRgName
  }

  dependsOn: [
    resourceGroup
  ]
}

// Creates a VNET peering from the AVD VNET to the hub VNET if we are AD Domain joining the session hosts
// No need for this to run if we are not AD domain joining
module virtualNetworkPeering2 'modules/virtualNetworkPeering.bicep' = if (!aadJoin) {
  name: 'vnetPeeringDeploy2'
  scope: az.resourceGroup(hubVnetRgName)
  params: {
    remoteVnetName: hubVnetName
    remoteVnetRsourceGroupName: hubVnetRgName
    remoteVnetSubscriptionId: subscription().id
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
    aadJoin: aadJoin
    hostPoolType: 'Pooled'
    maxSessionLimit: maxSessionLimit
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
    localAdminName: localAdminName
    localAdminPassword: localAdminPassword
    subnetName: 'sn-${name}'
    vmSize: vmSize
    count: vmCount
    licenseType: vmLicenseType
    aadJoin: aadJoin
    domainToJoin: domainToJoin
    domainPassword: domainPassword
    domainUserName: domainUserName
    ouPath: ouPath
    vnetId: virtualNetwork.outputs.id
  }

  dependsOn: [
    //virtualNetworkPeering1
    //virtualNetworkPeering2
    hostPool
  ]
}

