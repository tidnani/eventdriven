@description('Cosmos DB account name')
param cosmosDbAccountName string 

@description('Location for the Cosmos DB account.')
param location string = resourceGroup().location

@description('The name for the SQL API database')
param databaseName string

@description('The name for the SQL API container')
param containerName string

@description('The name for the event grid topic')
param eventGridName string

@description('Tags that our resources need')
param tags object

@description('Application Insights resource name')
param applicationInsightsName string

@description('Log Analytics resource name')
param logAnalyticsWorkspaceName string 

resource account 'Microsoft.DocumentDB/databaseAccounts@2022-05-15' = {
  name: toLower(cosmosDbAccountName)
  location: location
  tags: tags
  properties: {
    enableFreeTier: false
    databaseAccountOfferType: 'Standard'
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    capabilities: [
      {
        name: 'EnableServerless'
      }
    ]
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
  }
}

resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2022-05-15' = {
  parent: account
  name: databaseName
  tags: tags
  properties: {
    resource: {
      id: databaseName
    }
  }
}

resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2022-05-15' = {
  parent: database
  name: containerName
  tags: tags
  properties: {
    resource: {
      id: containerName
      partitionKey: {
        paths: [
          '/id'
        ]
        kind: 'Hash'
      }
      indexingPolicy: {
        indexingMode: 'consistent'
        includedPaths: [
          {
            path: '/*'
          }
        ]
        excludedPaths: [
          {
            path: '/_etag/?'
          }
        ]
      }
    }
  }
}

resource eventgrid 'Microsoft.EventGrid/topics@2023-06-01-preview' = {
  name: eventGridName
  location: location
  tags: tags
  sku: {
    name: 'Basic'
  }
  kind: 'Azure'
  properties: {
    disableLocalAuth: false
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}
