
using WorkspaceManagement.Application.Dtos.Projects;

namespace WorkspaceManagement.Application.Interfaces;

public interface IProjectRepository
{
    Task<List<ProjectDto>> GetByWorkspaceAsync(Guid workspaceId);

    Task<ProjectDto?> GetByIdAsync(Guid projectId, Guid workspaceId);

    Task<ProjectDto> CreateAsync( Guid workspaceId,Guid createdBy,CreateProjectRequestDto request);
}
