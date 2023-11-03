// Default URL for triggering event grid function in the local environment.
// http://localhost:7071/runtime/webhooks/EventGrid?functionName={functionname}

using Azure.Messaging.EventGrid;
using EventDriven.Models;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace EventDriven.Functions
{
    public static class ProcessOrderHandler
    {
        [Function(nameof(ProcessOrderHandler))]
        public static void Run([EventGridTrigger] EventGridEvent eventGridEvent, FunctionContext context)
        {
            var logger = context.GetLogger(nameof(ProcessOrderHandler));

            var order = JsonConvert.DeserializeObject<Order>(eventGridEvent.Data.ToString());

            logger.LogInformation($"Order Received for processing: Details are - CustomerName: {order.CustomerName}, CustomerId: {order.CustomerId}");

            //Process order
            
            logger.LogInformation($"Order Processed!");
        }
    }
}
