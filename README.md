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
# change these as needed
name=
location=
vnetAddressPrefix=
snetAddressPrefix=
hubVnetName=
hubVnetRGName=
hubVnetSubId=

# deploy resources into subscription
az deployment sub create --location $location -f ./main.bicep --parameters name=$name vnetAddressPrefix=$vnetAddressPrefix snetAddressPrefix=$snetAddressPrefix hubVnetName=$hubVnetName hubVnetName=$hubVnetName hubVnetRGName=$hubVnetRGName hubVnetSubId=$hubVnetSubId -c
```

## Resources

- https://github.com/Azure/bicep/blob/main/docs/cicd-with-bicep.md
- https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/bicep-modules