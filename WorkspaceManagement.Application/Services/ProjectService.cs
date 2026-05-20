using WorkspaceManagement.Application.Dtos.Projects;
using WorkspaceManagement.Application.Interfaces;

namespace WorkspaceManagement.Application.Services;

public class ProjectService(IProjectRepository _projectRepository) : IProjectService
{
    

    public async Task<List<ProjectDto>> GetByWorkspaceAsync( Guid workspaceId)
    {
        return await _projectRepository .GetByWorkspaceAsync(workspaceId);
    }

    public async Task<ProjectDto> CreateAsync(  Guid workspaceId, Guid createdBy,string role,  CreateProjectRequestDto request)
    {
        if (role != "Admin" && role != "Editor")
        {
            throw new UnauthorizedAccessException(
                "You do not have permissions to create projects");
        }

        return await _projectRepository.CreateAsync( workspaceId, createdBy,request);
    }
}