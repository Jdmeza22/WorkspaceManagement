
namespace WorkspaceManagement.Application.Dtos.Auth;

public class LoginResponseDto
{
    public Guid UserId { get; set; }

    public string Email { get; set; } = string.Empty;

    public string FullName { get; set; } = string.Empty;

    public List<WorkspaceDto> Workspaces { get; set; } = new List<WorkspaceDto>();
}
