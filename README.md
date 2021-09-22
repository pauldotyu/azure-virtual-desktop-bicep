# azure-virtual-desktop-bicep

> https://docs.microsoft.com/en-us/azure/templates/

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
# having some fun with petnames
# http://manpages.ubuntu.com/manpages/bionic/man1/petname.1.html
sudo apt-get install petname
name=$(petname --words 2 --separator "")
#name=demo-avd

# change these as needed
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
licenseType=<YOUR_VALUE>
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

## Resources

- https://github.com/Azure/bicep/blob/main/docs/cicd-with-bicep.md
- https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/bicep-modules