
using WorkspaceManagement.Application.Dtos.Auth;
using WorkspaceManagement.Application.Interfaces;
using WorkspaceManagement.Domain.Entities;
using WorkspaceManagement.Infrastructure.Authentication;

namespace WorkspaceManagement.Application.Services;

public class AuthService( IAuthRepository _authRepository, IJwtService _jwtService) : IAuthService
{
  
    public async Task<LoginResponseDto> LoginAsync( LoginRequestDto request)
    {
        User user = await _authRepository.GetUserByEmailAsync(request.Email);

        if (user is null){ throw new Exception("Invalid credentials"); }
        string hash = BCrypt.Net.BCrypt.HashPassword("Clave.123*");
        bool isValidPassword = BCrypt.Net.BCrypt.Verify(  request.Password, user.Password);

        if (!isValidPassword){ throw new Exception("Invalid credentials");}

        List<WorkspaceDto> workspaces = await _authRepository.GetUserWorkspacesAsync(user.Id);

        return new LoginResponseDto
        {
            UserId = user.Id,
            Email = user.Email,
            FullName = user.FullName,
            Workspaces = workspaces
        };
    }

    public async Task<GenerateTokenResponseDto> GenerateTokenAsync( GenerateTokenRequestDto request)
    {
        WorkspaceDto access = await _authRepository.GetWorkspaceAccessAsync(request.UserId,request.WorkspaceId);

        if (access is null){ throw new Exception("Workspace access denied");}

        string token = _jwtService.GenerateToken( request.UserId,request.WorkspaceId,access.Role);

        return new GenerateTokenResponseDto
        {
            Token = token
        };
    }
}
