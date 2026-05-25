using WorkspaceManagement.Application.Dtos.Auth;

namespace WorkspaceManagement.Application.Interfaces;

public interface IAuthService
{
    Task<LoginResponseDto> LoginAsync( LoginRequestDto request);

    Task<GenerateTokenResponseDto> GenerateTokenAsync( GenerateTokenRequestDto request);
}