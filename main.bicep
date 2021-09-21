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
param hubVnetName string
param hubVnetRGName string
param hubVnetSubId string

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
}
