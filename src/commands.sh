
# Tutorial: Communication between microservices in Azure Container Apps
# This works in conjunction with the project containerapps-albumui-csharp
# https://learn.microsoft.com/en-us/azure/container-apps/communicate-between-microservices?tabs=azure-powershell&pivots=acr-remote

ls 
az login
az account set --subscription $SUBSCRIPTIONID 

az upgrade
#!/bin/bash
: << 'COMMENT'
This is the first line of a multiline comment
This is the second line
COMMENT
# Next, install or update the Azure Container Apps extension for the CLI.
#az extension add --name containerapp --upgrade

# Register the Microsoft.App and Microsoft.OperationalInsights namespaces if you 
# haven't already registered them in your Azure subscription.
az provider register --namespace Microsoft.App
az provider register --namespace Microsoft.OperationalInsights

#setup environment variables
RESOURCE_GROUP="rg-containerapp"
LOCATION="westus"
ENVIRONMENT="env-album-containerapps"
API_NAME="album-api"
FRONTEND_NAME="album-ui"
GITHUB_USERNAME="bgfast"
CUSERNAME="crbrent"

# Define a container registry name unique to you.
ACR_NAME="crbrent"

#az acr build --registry $ACR_NAME --image $API_NAME .
# Build the container in Azure
az acr build --registry $ACR_NAME --image albumapp-ui .

API_BASE_URL=$(az containerapp show --resource-group $RESOURCE_GROUP --name $API_NAME --query properties.configuration.ingress.fqdn -o tsv)

az containerapp env create \
  --name $ENVIRONMENT \
  --resource-group $RESOURCE_GROUP \
  --location "$LOCATION"

az containerapp create \
  --name $FRONTEND_NAME \
  --resource-group $RESOURCE_GROUP \
  --environment $ENVIRONMENT \
  --image $ACR_NAME.azurecr.io/albumapp-ui  \
  --target-port 3000 \
  --env-vars API_BASE_URL=https://$API_BASE_URL \
  --ingress 'external' \
  --registry-server $ACR_NAME.azurecr.io \
  --registry-password $CPASSWORD \
  --registry-username $CUSERNAME \
  --query properties.configuration.ingress.fqdn

#docker login crbrent.azurecr.io

# Build the container with docker
#docker build --tag $ACR_NAME.azurecr.io/$API_NAME .



