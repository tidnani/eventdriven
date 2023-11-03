@description('Location for the resources')
param location string = resourceGroup().location

@description('Tags that our resources need')
param tags object

@description('The name of the function app')
param functionAppName string

@description('The name of the storage account')
param storageAccountName string

@description('The name of the app service plan')
param appServicePlanName string

@description('Cosmos DB account name')
param cosmosDbAccountName string 

@description('The name for the event grid topic')
param eventGridName string 

@description('Application Insights resource name')
param applicationInsightsName string 

resource cosmosdb 'Microsoft.DocumentDB/databaseAccounts@2022-05-15' existing = {
  name: cosmosDbAccountName
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

resource eventGrid 'Microsoft.EventGrid/topics@2023-06-01-preview' existing = {
  name: eventGridName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: 'Standard_ZRS'
  }
  kind: 'StorageV2'
  identity: {
    type: 'None'
  }
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    networkAcls: {
        bypass: 'AzureServices'
        defaultAction: 'Allow'
    }
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: appServicePlanName
  location: location
  properties: {
    reserved: true
  }
  sku: {
    name: 'B1'
  }
  kind: 'elastic'
}

resource functionApp 'Microsoft.Web/sites@2021-02-01' = {
  name: functionAppName
  location: location
  tags: tags
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    clientAffinityEnabled: false
    httpsOnly: true
    reserved: true
    siteConfig: {
      linuxFxVersion: 'DOTNET-ISOLATED|8.0'
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet-isolated'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'CosmosDBConnection'
          value: cosmosdb.listConnectionStrings().connectionStrings[0].connectionString
        }
        {
          name: 'AzureEventGridTopicKey'
          value: eventGrid.listKeys().key1
        }
        {
          name: 'AzureEventGridTopicEndpoint'
          value: 'https://${eventGridName}.northeurope-1.eventgrid.azure.net/api/events'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
      ]
    }
  }
}

resource authsettings 'Microsoft.Web/sites/config@2022-09-01' = {
  name: 'authsettingsV2'
  kind: 'string'
  parent: functionApp
  properties: {
    globalValidation: {
      excludedPaths: [
        'runtime/webhooks/EventGrid'
      ]
      redirectToProvider: 'Microsoft'
      requireAuthentication: true
      unauthenticatedClientAction: 'RedirectToLoginPage'
    }
    identityProviders: {
      azureActiveDirectory: {
        enabled: true
        registration: {
          clientId: 'fbef33bd-41c0-4e9c-b064-2c06259aed33'
        }
      }
    }
  }
}
