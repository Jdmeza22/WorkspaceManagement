using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System.Data;

namespace WorkspaceManagement.Infrastructure.Persistance;

public class SqlConnectionFactory(IConfiguration _configuration)
{
    public IDbConnection CreateConnection()
    {
        return new SqlConnection(
            _configuration.GetConnectionString("DefaultConnection"));
    }
}
