param name string
param tags object
param location string

//https://docs.microsoft.com/en-us/azure/templates/microsoft.network/networksecuritygroups?tabs=bicep
resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-04-01' = {
  name: 'nsg-${name}'
  location: location
  properties: {
    securityRules: [
      //https://docs.microsoft.com/en-us/azure/api-management/api-management-using-with-vnet#-common-network-configuration-issues
    ]
  }
  tags: tags
}

output id string = networkSecurityGroup.id
