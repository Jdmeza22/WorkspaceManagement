

namespace WorkspaceManagement.Application.Dtos.Auth;

public class GenerateTokenRequestDto
{
    public Guid UserId { get; set; }
    public Guid WorkspaceId { get; set; }
}
