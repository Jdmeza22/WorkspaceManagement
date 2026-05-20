using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Security.Claims;
using WorkspaceManagement.Application.Dtos.Projects;
using WorkspaceManagement.Application.Interfaces;

namespace WorkspaceManagement.Api.Controllers;

[ApiController]
[Route("api/projects")]
[Authorize]
public class ProjectsController( IProjectService _projectService) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetProject()
    {
        Guid workspaceId = GetWorkspaceId();
        List<ProjectDto> projects = await _projectService.GetByWorkspaceAsync(workspaceId);
        return Ok(projects);
    }

    [HttpPost]
    public async Task<IActionResult> CreateProject( [FromBody] CreateProjectRequestDto request)
    {
        Guid workspaceId = GetWorkspaceId();
        Guid userId = GetUserId();
        string role = GetRole();

        ProjectDto project = await _projectService.CreateAsync(workspaceId, userId, role,  request);

        return Ok(project);
    }

    private Guid GetWorkspaceId()
    {
        var workspaceId = User.FindFirst("workspaceId")?.Value;
        return Guid.Parse(workspaceId!);
    }

    private Guid GetUserId()
    {
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                     ?? User.FindFirst(ClaimTypes.Name)?.Value
                     ?? User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                     ?? User.FindFirst("sub")?.Value;

        return Guid.Parse(userId!);
    }

    private string GetRole()
    {
        return User.FindFirst(ClaimTypes.Role)?.Value!;
    }
}