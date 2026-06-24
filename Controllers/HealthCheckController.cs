using Microsoft.AspNetCore.Mvc;
using Dotnetproject.Models;
using Dotnetproject.Services;

namespace Dotnetproject.Controllers;

[ApiController]
[Route("api/[controller]")]
public class HealthCheckController : ControllerBase
{
    private readonly IHealthService _healthService;

    public HealthCheckController(IHealthService healthService)
    {
        _healthService = healthService;
    }

    [HttpGet]
    public ActionResult<HealthStatus> Get()
    {
        var status = _healthService.GetHealthStatus();
        return Ok(status);
    }
}
