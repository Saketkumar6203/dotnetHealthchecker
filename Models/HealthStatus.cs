using System;

namespace Dotnetproject.Models;

public class HealthStatus
{
    public string Status { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public DateTime TimestampUtc { get; set; }
}
