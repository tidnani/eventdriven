using System.Configuration;
using Azure;
using Azure.Messaging.EventGrid;
using Microsoft.Azure.Cosmos;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

public class Program
{
    public static void Main()
    {
        var host = new HostBuilder()
            .ConfigureFunctionsWorkerDefaults()
            .ConfigureServices((hostContext, services) =>
            {
                var connectionString = hostContext.Configuration["CosmosDBConnection"];
                services.AddSingleton((serviceProvider) =>
           {
               return new CosmosClient(connectionString);
           })
           .AddSingleton<EventGridPublisherClient>(new EventGridPublisherClient(
            new Uri(hostContext.Configuration["AzureEventGridTopicEndpoint"]), 
            new AzureKeyCredential(hostContext.Configuration["AzureEventGridTopicKey"])));
            }).Build();
        host.Run();
    }
}