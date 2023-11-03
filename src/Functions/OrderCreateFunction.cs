using System.Net;
using EventDriven.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Cosmos;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Microsoft.AspNetCore.Http;

namespace EventDriven.Functions
{
    public class OrderCreateFunction
    {
        private readonly ILogger _logger;

        private readonly CosmosClient _cosmosClient;

        public OrderCreateFunction(ILoggerFactory loggerFactory, CosmosClient cosmosClient)
        {
            _logger = loggerFactory.CreateLogger<OrderCreateFunction>();
            _cosmosClient = cosmosClient;
        }

        [Function("OrderCreateFunction")]
        public async Task<IActionResult> Run([HttpTrigger(AuthorizationLevel.Anonymous, "post")] HttpRequestData req)
        {
            _logger.LogInformation("Request for Order Creation received!");

            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            dynamic data = JsonConvert.DeserializeObject(requestBody);

            var order = new Order{
                Id = Guid.NewGuid().ToString(),
                CustomerId = data?.CustomerId,
                CustomerName = data?.CustomerName,
                CustomerEmail = data?.CustomerEmail
            };

            var container = _cosmosClient.GetContainer("orders", "events");
            await container.CreateItemAsync(order);
            _logger.LogInformation("Request for Order Creation accepted!");

            return new AcceptedResult();
        }
    }
}
