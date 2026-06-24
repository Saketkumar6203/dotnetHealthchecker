using Microsoft.AspNetCore.Mvc;
using Moq;
using Xunit;
using Dotnetproject.Controllers;
using Dotnetproject.Models;
using Dotnetproject.Services;

namespace Dotnetproject.Tests;

public class HealthCheckControllerTests
{
    [Fact]
    public void Get_ReturnsOkResult_WithHealthStatus()
    {
        // Arrange
        var expectedStatus = new HealthStatus
        {
            Status = "Healthy",
            Description = "The API is running normally.",
            TimestampUtc = DateTime.UtcNow
        };

        var healthServiceMock = new Mock<IHealthService>();
        healthServiceMock
            .Setup(service => service.GetHealthStatus())
            .Returns(expectedStatus);

        var controller = new HealthCheckController(healthServiceMock.Object);

        // Act
        var result = controller.Get();

        // Assert
        var okResult = Assert.IsType<OkObjectResult>(result.Result);
        var actualStatus = Assert.IsType<HealthStatus>(okResult.Value);
        Assert.Equal(expectedStatus.Status, actualStatus.Status);
        Assert.Equal(expectedStatus.Description, actualStatus.Description);
        Assert.Equal(expectedStatus.TimestampUtc, actualStatus.TimestampUtc);
    }
}
