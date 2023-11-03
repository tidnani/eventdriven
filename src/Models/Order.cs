namespace EventDriven.Models
{
    using Newtonsoft.Json;

    public class Order
    {
        [JsonProperty(PropertyName = "id")]
        public string Id { get; set; }

        [JsonProperty(PropertyName = "customerId")]
        public string CustomerId { get; set; }

        [JsonProperty(PropertyName = "customerName")]
        public string CustomerName { get; set; }

        [JsonProperty(PropertyName = "customerEmail")]
        public string CustomerEmail { get; set; }
    }
}