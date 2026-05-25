
namespace WorkspaceManagement.Application.Dtos.Auth;

public class WorkspaceDto
{
    public Guid WorkspaceId { get; set; }
    public string WorkspaceName { get; set; } = string.Empty;
    public string Role { get; set; } = string.Empty;
}
