using Dapper;
using WorkspaceManagement.Application.Dtos.Auth;
using WorkspaceManagement.Application.Interfaces;
using WorkspaceManagement.Domain.Entities;
using WorkspaceManagement.Infrastructure.Persistance;

namespace WorkspaceManagement.Infrastructure.Repository;

public class AuthRepository(SqlConnectionFactory _connectionFactory) : IAuthRepository
{
    public async Task<User?> GetUserByEmailAsync(string email)
    {
        using var connection = _connectionFactory.CreateConnection();

        return await connection.QueryFirstOrDefaultAsync<User>(
            "Auth_Login",
            new
            {
                Email = email
            },
            commandType: System.Data.CommandType.StoredProcedure);
    }

    public async Task<List<WorkspaceDto>> GetUserWorkspacesAsync(Guid userId)
    {
        using var connection = _connectionFactory.CreateConnection();

        var result = await connection.QueryAsync<WorkspaceDto>(
            "Auth_GetUserWorkspaces",
            new
            {
                UserId = userId
            },
            commandType: System.Data.CommandType.StoredProcedure);

        return result.ToList();
    }

    public async Task<WorkspaceDto?> GetWorkspaceAccessAsync(Guid userId,Guid workspaceId)
    {
        using var connection = _connectionFactory.CreateConnection();

        return await connection.QueryFirstOrDefaultAsync<WorkspaceDto>(
            "Auth_GetWorkspaceAccess",
            new
            {
                UserId = userId,
                WorkspaceId = workspaceId
            },
            commandType: System.Data.CommandType.StoredProcedure);
    }
}