using Dapper;
using System.Data;
using WorkspaceManagement.Application.Dtos.Projects;
using WorkspaceManagement.Application.Interfaces;
using WorkspaceManagement.Infrastructure.Persistance;

namespace WorkspaceManagement.Infrastructure.Repositories;

public class ProjectRepository(SqlConnectionFactory _connectionFactory) : IProjectRepository
{
    
    public async Task<List<ProjectDto>> GetByWorkspaceAsync( Guid workspaceId)
    {
        using var connection = _connectionFactory.CreateConnection();

        var result = await connection.QueryAsync<ProjectDto>(
            "Projects_GetByWorkspace",
            new
            {
                WorkspaceId = workspaceId
            },
            commandType: CommandType.StoredProcedure);

        return result.ToList();
    }

    public async Task<ProjectDto?> GetByIdAsync( Guid projectId, Guid workspaceId)
    {
        using var connection = _connectionFactory.CreateConnection();

        return await connection.QueryFirstOrDefaultAsync<ProjectDto>(
            "Projects_GetById",
            new
            {
                ProjectId = projectId,
                WorkspaceId = workspaceId
            },
            commandType: CommandType.StoredProcedure);
    }

    public async Task<ProjectDto> CreateAsync(Guid workspaceId,Guid createdBy,CreateProjectRequestDto request)
    {
        using var connection = _connectionFactory.CreateConnection();

        return await connection.QueryFirstAsync<ProjectDto>(
            "Projects_Create",
            new
            {
                WorkspaceId = workspaceId,
                Name = request.Name,
                Description = request.Description,
                CreatedBy = createdBy
            },
            commandType: CommandType.StoredProcedure);
    }
}