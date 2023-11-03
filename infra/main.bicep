@description('Specifies the location for resources.')
param location2 string = 'northeurope'

@description('Specifies the location for resources.')
param location string = 'northeurope'

@description('Tags that our resources need')
param tags object

@description('The name of the app service plan')
param appServicePlanName string

@description('The name of the function app')
param functionAppName string

@description('The name of the storage account')
param storageAccountName string

@description('The name for the SQL API database')
param databaseName string = 'orders'

@description('The name for the SQL API container')
param containerName string = 'events'

@description('The name for the event grid topic')
param eventGridName string 

@description('Cosmos DB account name')
param cosmosDbAccountName string 

@description('Application Insights resource name')
param applicationInsightsName string

@description('Log Analytics resource name')
param logAnalyticsWorkspaceName string 

module compute 'compute.bicep'= {
  name: 'compute-deployment'
  params: {
    location: location
    tags: tags
    appServicePlanName: appServicePlanName
    functionAppName: functionAppName
    storageAccountName: storageAccountName
    cosmosDbAccountName: cosmosDbAccountName
    eventGridName: eventGridName
    applicationInsightsName: applicationInsightsName
  }
  dependsOn:[
    storage
  ]
}

module storage 'storage.bicep'= {
  name: 'storage-deployment'
  params: {
    location: location2
    databaseName:databaseName
    containerName:containerName
    eventGridName: eventGridName
    tags: tags
    cosmosDbAccountName: cosmosDbAccountName
    applicationInsightsName: applicationInsightsName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
  }
}
