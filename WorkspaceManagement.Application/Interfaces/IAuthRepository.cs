
using WorkspaceManagement.Application.Dtos.Auth;
using WorkspaceManagement.Domain.Entities;

namespace WorkspaceManagement.Application.Interfaces;

public interface IAuthRepository
{
    Task<User?> GetUserByEmailAsync(string email);
    Task<List<WorkspaceDto>> GetUserWorkspacesAsync(Guid userId);
    Task<WorkspaceDto?> GetWorkspaceAccessAsync(Guid userId, Guid workspaceId);
}
