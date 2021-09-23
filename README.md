# azure-virtual-desktop-bicep

> WORK IN PROGRESS BUT ENOUGH TO GET YOUR GOING 😊

Running this repo requires the following:
- Non-overlapping private IP space
- Domain Controller in Azure
- Permissions to peer the AVD vnet with DC vnet
- Domain joiner account credentials and OU path

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
name=<YOUR_VALUE>
location=<YOUR_VALUE>
vnetAddressPrefix=<YOUR_VALUE>
snetAddressPrefix=<YOUR_VALUE>
snetName=<YOUR_VALUE>
hubVnetName=<YOUR_VALUE>
hubVnetRGName=<YOUR_VALUE>
hubVnetSubId=<YOUR_VALUE>
dnsServer=<YOUR_VALUE>
localAdminName=<YOUR_VALUE>
localAdminPassword=<YOUR_VALUE>
vmSize=<YOUR_VALUE>
licenseType=Windows_Client
domainToJoin=<YOUR_VALUE>
domainPassword=<YOUR_VALUE>
domainUserName=<YOUR_VALUE>
ouPath=<YOUR_VALUE>

# deploy resources into subscription
az deployment sub create --location $location -f ./main.bicep --parameters name=$name \
  vnetAddressPrefix=$vnetAddressPrefix \
  snetAddressPrefix=$snetAddressPrefix \
  snetName=$snetName \
  hubVnetName=$hubVnetName \
  hubVnetName=$hubVnetName \
  hubVnetRGName=$hubVnetRGName \
  hubVnetSubId=$hubVnetSubId \
  dnsServer=$dnsServer \
  localAdminName=$localAdminName \
  localAdminPassword=$localAdminPassword \
  vmSize=$vmSize \
  licenseType=$licenseType \
  domainToJoin=$domainToJoin \
  domainPassword=$domainPassword \
  domainUserName=$domainUserName \
  ouPath=$ouPath \
  -c
```

## Destroy

```sh
# remove the session host from the host pool
az group delete -n rg-$name -y
az network vnet peering delete -n vn-adds_to_vn-$name -g rg-adds --vnet-name vn-adds
```

## Resources

- https://github.com/Azure/bicep/blob/main/docs/cicd-with-bicep.md
- https://docs.microsoft.com/en-us/azure/templates
- https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/bicep-modules
- https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/loop-resources#resource-iteration-with-condition

## Some notes

The `Microsoft.DesktopVirtualization` namespace isn't well documented yet in https://docs.microsoft.com/en-us/azure/templates/, so I recommend you reference the REST API docs to determine which API versions you should be using https://docs.microsoft.com/en-us/rest/api/desktopvirtualization/.

Common VM extension error messages: https://docs.microsoft.com/en-us/troubleshoot/azure/virtual-machines/error-messages
