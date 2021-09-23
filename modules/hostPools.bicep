param name string
param tags object
param location string
@allowed([
  'Personal'
  'Pooled'
])
param hostPoolType string

param baseTime string = utcNow('u')

var expirationTime = dateTimeAdd(baseTime, 'PT48H')

//https://docs.microsoft.com/en-us/rest/api/desktopvirtualization/host-pools/create-or-update
//https://github.com/Azure/bicep-types-az/blob/main/generated/desktopvirtualization/microsoft.desktopvirtualization/2021-07-12/types.md
resource hostPool 'Microsoft.DesktopVirtualization/hostPools@2021-03-09-preview' = {
  name: 'hp-${name}'
  location: location
  tags: tags
  properties: {
    hostPoolType: hostPoolType
    loadBalancerType: 'BreadthFirst'
    preferredAppGroupType: 'Desktop'
    maxSessionLimit: 999999
    startVMOnConnect: false
    validationEnvironment: false
    customRdpProperty: 'drivestoredirect:s:*;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:1;redirectprinters:i:1;devicestoredirect:s:*;redirectcomports:i:1;redirectsmartcards:i:1;usbdevicestoredirect:s:*;enablecredsspsupport:i:1;use multimon:i:1;'
    registrationInfo: {
      expirationTime: expirationTime
      token: null
      registrationTokenOperation: 'Update'
    }
  }
}

output id string = hostPool.id
