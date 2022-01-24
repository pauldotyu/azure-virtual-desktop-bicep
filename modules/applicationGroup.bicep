param name string
param tags object
param location string
param hostPoolId string
param rbacObjectId string
param rbacPrincipalType string

resource applicationGroup 'Microsoft.DesktopVirtualization/applicationGroups@2021-03-09-preview' = {
  name: 'ag-${name}'
  location: location
  tags: tags
  properties: {
    applicationGroupType: 'Desktop'
    hostPoolArmPath: hostPoolId
  }
}

// // Assign RBAC permissions to the application group
// resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
//   name: 'rbac${name}'
//   scope: applicationGroup
//   properties: {
//     roleDefinitionId: '1d18fff3-a72a-46b5-b4a9-0b38a3cd7e63' // Desktop Virtualization User
//     principalId: rbacObjectId
//     principalType: rbacPrincipalType
//   }
// }

output id string = applicationGroup.id
