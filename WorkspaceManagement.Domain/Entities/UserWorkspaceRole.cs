

namespace WorkspaceManagement.Domain.Entities;

public class UserWorkspaceRole
{
    public Guid UserId { get; set; }

    public User User { get; set; } = null!;

    public Guid WorkspaceId { get; set; }

    public Workspace Workspace { get; set; } = null!;

    public int RoleId { get; set; }

    public Role Role { get; set; } = null!;

    public DateTime AssignedAt { get; set; }
}
