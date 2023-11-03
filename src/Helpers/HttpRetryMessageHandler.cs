using Microsoft.Extensions.Logging;
using Polly;

public class HttpRetryMessageHandler : DelegatingHandler
{
    [System.Diagnostics.CodeAnalysis.SuppressMessage("Style", "IDE1006:Naming Styles", Justification = "&lt;Pending>")]
    private const int MAXIMUM_RETRY_ATTEMPT = 3;
    private readonly ILogger _logger;

    public HttpRetryMessageHandler(
        ILogger logger,
        HttpClientHandler handler) : base(handler)
    {
        _logger = logger;
    }

    protected override Task<HttpResponseMessage> SendAsync(
        HttpRequestMessage request,
        CancellationToken cancellationToken) =>

        // Will retry again at the 3 second, 9 second and 27 second mark before throwing an exception

        Policy
            .Handle<HttpRequestException>()
            .Or<TaskCanceledException>()
            .OrResult<HttpResponseMessage>(x => !x.IsSuccessStatusCode)
            .WaitAndRetryAsync(
                MAXIMUM_RETRY_ATTEMPT,
                retryAttempt => TimeSpan.FromSeconds(Math.Pow(MAXIMUM_RETRY_ATTEMPT, retryAttempt)),
                onRetry: (exception, nextRetry, context) =>
                {
                    _logger.LogInformation($"An error was encountered, will retry again in {nextRetry.TotalSeconds} second(s)...");
                })
            .ExecuteAsync(() => base.SendAsync(request, cancellationToken));
}