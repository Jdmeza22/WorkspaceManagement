namespace WorkspaceManagement.Application.Dtos.Projects;

public class CreateProjectRequestDto
{
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
}
