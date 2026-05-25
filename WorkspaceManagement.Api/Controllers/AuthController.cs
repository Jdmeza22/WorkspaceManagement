using Azure;
using Microsoft.AspNetCore.Mvc;
using WorkspaceManagement.Application.Common.Responses;
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
        LoginResponseDto response = await _authService.LoginAsync(request);
        return Ok(ApiResponse<LoginResponseDto>.Ok(response));
    }

    [HttpPost("token")]
    public async Task<IActionResult> GenerateToken( [FromBody] GenerateTokenRequestDto request)
    {
        GenerateTokenResponseDto response = await _authService.GenerateTokenAsync(request);
        return Ok(ApiResponse<GenerateTokenResponseDto>.Ok(response));   
    }
}