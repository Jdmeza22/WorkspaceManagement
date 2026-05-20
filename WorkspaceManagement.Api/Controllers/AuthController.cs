using Azure;
using Microsoft.AspNetCore.Mvc;
using WorkspaceManagement.Application.Dtos.Auth;
using WorkspaceManagement.Application.Interfaces;

namespace WorkspaceManagement.Api.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController(IAuthService _authService) : ControllerBase
{
   
    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequestDto request)
    {
        try
        {
            LoginResponseDto response = await _authService.LoginAsync(request);
            return Ok(response);
        }
        catch (Exception ex)
        {
            return Unauthorized(new { message = ex.Message });
        }
    }

    [HttpPost("token")]
    public async Task<IActionResult> GenerateToken( [FromBody] GenerateTokenRequestDto request)
    {
        try
        {
            GenerateTokenResponseDto response = await _authService.GenerateTokenAsync(request);
            return Ok(response);
        }
        catch (Exception ex)
        {
            return Unauthorized(new { message = ex.Message });
        }
    }
}