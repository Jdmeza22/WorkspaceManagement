
namespace WorkspaceManagement.Infrastructure.Authentication;
public interface IJwtService
{
    string GenerateToken( Guid userId,Guid workspaceId, string role);
}