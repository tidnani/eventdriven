using Azure.Messaging.EventGrid;
using EventDriven.Models;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace EventDriven.Functions
{
    public class CosmosToEventGridFunction
    {
        private readonly ILogger _logger;

        private readonly IConfiguration _config;

        private readonly EventGridPublisherClient _client;

        public CosmosToEventGridFunction(ILoggerFactory loggerFactory, IConfiguration config, EventGridPublisherClient eventGridPublisherClient)
        {
            _logger = loggerFactory.CreateLogger<CosmosToEventGridFunction>();
            _config = config;
            _client = eventGridPublisherClient;
        }

        [Function("CosmosToEventGridFunction")]
        public async Task RunAsync([CosmosDBTrigger(
            databaseName: "orders",
            containerName: "events",
            Connection = "CosmosDBConnection",
            LeaseContainerName = "leases",
            CreateLeaseContainerIfNotExists = true
            )] IReadOnlyList<Order> documents)
        {
            _logger.LogInformation("CosmosDBTrigger fired.");

            if (documents != null)
            {
                _logger.LogInformation($"Received {documents.Count} document(s) from Cosmos DB.");

                var eventGridEventList =
                    new List<EventGridEvent>();

                foreach (var document in documents)
                {
                    var eventGridEvent =
                        new EventGridEvent("department/widget", "OrderCreated", "1.0", document);

                    eventGridEventList.Add(
                        eventGridEvent);
                }

                _logger.LogInformation($"Sending a batch of {documents.Count} event(s) to Azure Event Grid for processing.");

                await _client.SendEventsAsync(eventGridEventList);
            }
        }
    }
}
