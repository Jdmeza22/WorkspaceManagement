FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build

WORKDIR /src

COPY ["WorkspaceManagement.Api/WorkspaceManagement.Api.csproj", "WorkspaceManagement.Api/"]
COPY ["WorkspaceManagement.Application/WorkspaceManagement.Application.csproj", "WorkspaceManagement.Application/"]
COPY ["WorkspaceManagement.Domain/WorkspaceManagement.Domain.csproj", "WorkspaceManagement.Domain/"]
COPY ["WorkspaceManagement.Infrastructure/WorkspaceManagement.Infrastructure.csproj", "WorkspaceManagement.Infrastructure/"]



RUN dotnet restore "WorkspaceManagement.Api/WorkspaceManagement.Api.csproj"
COPY . .
WORKDIR "/src/WorkspaceManagement.Api"
RUN dotnet publish "WorkspaceManagement.Api.csproj" -c Release -o /app/publish
FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app
COPY --from=build /app/publish .
EXPOSE 8080
ENTRYPOINT ["dotnet", "WorkspaceManagement.Api.dll"]