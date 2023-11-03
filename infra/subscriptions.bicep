@description('Name of the functionApp')
param functionAppName string

@description('Name of the subscription')
param eventGridSubscriptionName string

@description('Name of the event Grid')
param eventGridName string

resource eventgrid 'Microsoft.EventGrid/topics@2023-06-01-preview' existing = {
  name: eventGridName
}

resource eventgridsubscription 'Microsoft.EventGrid/eventSubscriptions@2023-06-01-preview' = {
  name: eventGridSubscriptionName
  scope: eventgrid
  properties: {
    destination: {
      endpointType: 'AzureFunction'
      properties: {
        maxEventsPerBatch: 10
        preferredBatchSizeInKilobytes: 4
        resourceId: resourceId('Microsoft.Web/sites/functions', functionAppName, 'ProcessOrderHandler')
      }
    }
  }
}
