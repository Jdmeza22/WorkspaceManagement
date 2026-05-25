
namespace WorkspaceManagement.Domain.Entities;

public class Project
{
    public Guid Id { get; set; }
    public Guid WorkspaceId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string Status { get; set; } = string.Empty;
    public Guid CreatedBy { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}
