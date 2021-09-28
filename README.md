# azure-virtual-desktop-bicep

> WORK IN PROGRESS BUT ENOUGH TO GET YOU GOING 😊

Use this repo to quickly deploy AVD in your environment. There are two options: you can choose to deploy AzureAD-Joined session hosts or deploy AD-Joined session hosts.

AzureAD-Joined session hosts requires the following:
- Non-overlapping private IP space
- Permissions to grant users the "Virtual Machine User Login" role at the resource group level for to login

AD-Joined session hosts requires the following:
- Non-overlapping private IP space
- Domain Controller in Azure
- Permissions to peer the AVD vnet with DC vnet
- Domain-joiner account credentials and OU path

Depending on which option you choose, you will need to use the appropriate parameters-*.json file. There are sample values in each of these files.

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
localAdminName=<YOUR_VALUE>
localAdminPassword=<YOUR_VALUE>

# Deploy AAD-Joined AVD
az deployment sub create --location $location -f ./main.bicep --parameters name=$name localAdminName=$localAdminName localAdminPassword=$localAdminPassword --parameters @parameters-aad-join-example.json -c


# Deploy AD-Joined AVD
domainUserName=<YOUR_VALUE>
domainPassword=<YOUR_VALUE>
az deployment sub create --location $location -f ./main.bicep --parameters name=$name localAdminName=$localAdminName localAdminPassword=$localAdminPassword domainUserName=$domainUserName domainPassword=$domainPassword --parameters @parameters-ad-join-example.json -c
```

## Destroy

```sh
# remove the session host from the host pool
az desktopvirtualization hostpool delete --force true --name hp-$name --resource-group rg-$name
az group delete -n rg-$name -y
# do this only if you AD joined and created a VNET peering
az network vnet peering delete -n vn-adds_to_vn-$name -g rg-adds --vnet-name vn-adds
```

## Resources

- https://github.com/Azure/bicep/blob/main/docs/cicd-with-bicep.md
- https://github.com/Azure/bicep-types-az/blob/main/generated/desktopvirtualization/microsoft.desktopvirtualization/2021-07-12/types.md
- https://docs.microsoft.com/en-us/cli/azure/desktopvirtualization?view=azure-cli-latest
- https://docs.microsoft.com/en-us/azure/templates/
- https://docs.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks?tabs=bicep
- https://docs.microsoft.com/en-us/azure/templates/microsoft.network/networksecuritygroups?tabs=bicep
- https://docs.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines?tabs=bicep
- https://docs.microsoft.com/en-us/azure/templates/microsoft.desktopvirtualization/applicationgroups?tabs=bicep
- https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/bicep-modules
- https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/loop-resources#resource-iteration-with-condition
- https://docs.microsoft.com/en-us/azure/api-management/api-management-using-with-vnet#-common-network-configuration-issues
- https://catalogartifact.azureedge.net/publicartifacts/Microsoft.Hostpool-ARM-1.10.0/managedDisks-galleryvm.json

## Some notes

Common VM extension error messages: https://docs.microsoft.com/en-us/troubleshoot/azure/virtual-machines/error-messages
