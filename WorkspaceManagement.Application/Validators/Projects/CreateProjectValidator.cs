using FluentValidation;
using WorkspaceManagement.Application.Dtos.Projects;

namespace WorkspaceManagement.Application.Validators.Projects;

public class CreateProjectValidator
    : AbstractValidator<CreateProjectRequestDto>
{
    public CreateProjectValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty()
            .MaximumLength(150);

        RuleFor(x => x.Description)
            .MaximumLength(1000);
    }
}