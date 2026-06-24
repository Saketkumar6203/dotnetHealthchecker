using System;
using Dotnetproject.Models;

namespace Dotnetproject.Services;

public class HealthService : IHealthService
{
    public HealthStatus GetHealthStatus()
    {
        return new HealthStatus
        {
            Status = "Healthy",
            Description = "The API is running normally.",
            TimestampUtc = DateTime.UtcNow
        };
    }
}
