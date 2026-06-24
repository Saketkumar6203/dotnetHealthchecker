using Dotnetproject.Models;

namespace Dotnetproject.Services;

public interface IHealthService
{
    HealthStatus GetHealthStatus();
}
