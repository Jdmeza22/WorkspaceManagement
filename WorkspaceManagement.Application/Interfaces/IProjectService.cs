using WorkspaceManagement.Application.Dtos.Projects;
namespace WorkspaceManagement.Application.Interfaces;

public interface IProjectService
{
    Task<List<ProjectDto>> GetByWorkspaceAsync( Guid workspaceId);
    Task<ProjectDto> CreateAsync( Guid workspaceId,  Guid createdBy, string role,  CreateProjectRequestDto request);
}