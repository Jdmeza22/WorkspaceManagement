
using System.ComponentModel.DataAnnotations;
using System.Net;
using System.Text.Json;
using WorkspaceManagement.Application.Common.Exceptions;
using WorkspaceManagement.Application.Common.Responses;

namespace WorkspaceManagement.Api.Middlewares;

public class ExceptionMiddleware(RequestDelegate _next)
{
    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            await HandleExceptionAsync(context, ex);
        }
    }

    private static async Task HandleExceptionAsync( HttpContext context,Exception exception)
    {
        HttpStatusCode statusCode;
        object response;

        switch (exception)
        {
            case FluentValidation.ValidationException validationException:

                statusCode = HttpStatusCode.BadRequest;
                response = ApiResponse<object>.Fail( "Validation errors", validationException.Errors.Select(x => x.ErrorMessage).ToList());

                break;

            case UnauthorizedAccessException:

                statusCode = HttpStatusCode.Unauthorized;
                response = ApiResponse<object>.Fail(exception.Message);
                break;

            case ForbiddenException:

                statusCode = HttpStatusCode.Forbidden;
                response = ApiResponse<object>.Fail(exception.Message);
                break;

            case NotFoundException:

                statusCode = HttpStatusCode.NotFound;
                response = ApiResponse<object>.Fail( exception.Message);
                break;

            case BadRequestException:

                statusCode = HttpStatusCode.BadRequest;
                response = ApiResponse<object>.Fail(exception.Message);
                break;

            default:

                statusCode = HttpStatusCode.InternalServerError;
                response = ApiResponse<object>.Fail( "Internal server error");
                break;
        }

        context.Response.ContentType = "application/json";
        context.Response.StatusCode = (int)statusCode;
        var json = JsonSerializer.Serialize(response);
        await context.Response.WriteAsync(json);
    }
}