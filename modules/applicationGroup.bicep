param name string
param tags object
param location string
param hostPoolId string

//https://docs.microsoft.com/en-us/rest/api/desktopvirtualization/application-groups/create-or-update
resource applicationGroup 'Microsoft.DesktopVirtualization/applicationGroups@2021-03-09-preview' = {
  name: 'ag-${name}'
  location: location
  tags: tags
  properties: {
    applicationGroupType: 'Desktop'
    hostPoolArmPath: hostPoolId
  }
}

output id string = applicationGroup.id
