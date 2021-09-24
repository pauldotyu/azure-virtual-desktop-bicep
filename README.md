# azure-virtual-desktop-bicep

> WORK IN PROGRESS BUT ENOUGH TO GET YOU GOING 😊

This branch will enable the Azure AD Join feature so that you do not need line of sight to an on-prem or virtualized Active Directory Domain Controller. You will need to make sure your users have been asssigned the "Virtual Machine User Login" role at the resource group level in order for them to login.

Running this repo requires the following:
- Non-overlapping private IP space

Take a look at all the required variables below, fill in the values, and flex your bicep.

The easiest way to get started is by cloning this repo using Azure Cloud Shell and running az cli commands in bash

## Install azure-cli

```sh
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

## Install bicep

```sh
az bicep install
```

## Upgrade bicep

```sh
az bicep upgrade
```

## Build your bicep

```sh
az bicep build --file main.bicep
```

## Flex your bicep

```sh
# use this if you want to have some fun with petnames
# http://manpages.ubuntu.com/manpages/bionic/man1/petname.1.html
sudo apt-get install petname
name=$(petname --words 2 --separator "")
echo $name

# change these as needed
#name=<YOUR_VALUE>
location=<YOUR_VALUE>
vnetAddressPrefix=<YOUR_VALUE>
snetAddressPrefix=<YOUR_VALUE>
snetName=sn-$name
localAdminName=<YOUR_VALUE>
localAdminPassword=<YOUR_VALUE>
vmSize=<YOUR_VALUE>
vmCount=<YOUR_VALUE>

# deploy resources into subscription
az deployment sub create --location $location -f ./main.bicep --parameters name=$name \
  vnetAddressPrefix=$vnetAddressPrefix \
  snetAddressPrefix=$snetAddressPrefix \
  snetName=$snetName \
  localAdminName=$localAdminName \
  localAdminPassword=$localAdminPassword \
  vmSize=$vmSize \
  vmCount=$vmCount \
  -c
```

## Destroy

```sh
# you might need to manually remove the session hosts from the host pool to delete the resource group
az group delete -n rg-$name -y

# delete the vnet peering from your DC vnet
az network vnet peering delete -n <YOUR_VALUE> -g <YOUR_VALUE> --vnet-name <YOUR_VALUE>
```

## Resources

- https://github.com/Azure/bicep/blob/main/docs/cicd-with-bicep.md
- https://docs.microsoft.com/en-us/azure/templates
- https://docs.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines?tabs=bicep
- https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/bicep-modules
- https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/loop-resources#resource-iteration-with-condition
- https://catalogartifact.azureedge.net/publicartifacts/Microsoft.Hostpool-ARM-1.10.0/managedDisks-galleryvm.json

## Some notes

The `Microsoft.DesktopVirtualization` namespace isn't well documented yet in https://docs.microsoft.com/en-us/azure/templates/, so I recommend you reference the REST API docs to determine which API versions you should be using https://docs.microsoft.com/en-us/rest/api/desktopvirtualization/.

Common VM extension error messages: https://docs.microsoft.com/en-us/troubleshoot/azure/virtual-machines/error-messages
