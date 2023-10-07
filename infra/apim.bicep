@description('Apim Service name')
param apimServiceName string

@description('Service URL of the backend API')
param serviceUrl string

@description('OpenApi/Swagger of the backend API')
param apiFormatValue string

resource apimService 'Microsoft.ApiManagement/service@2021-08-01' existing = {
  name: apimServiceName
}

resource apiResource 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
  parent: apimService
  name: 'api-hello'
  properties: {
    description: 'Hello Api'
    type: 'http'
    isCurrent: false
    subscriptionRequired: false
    displayName: 'Hello Api'
    serviceUrl: serviceUrl
    path: '/uk/helloworld'
    protocols: [
      'https'
    ]
    value: !empty(apiFormatValue)? apiFormatValue: null
    format: 'openapi+json'
    apiType: 'http'
  }
}
