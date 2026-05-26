IF DB_ID('ElogicDB') IS NULL
BEGIN
    CREATE DATABASE ElogicDB;
END
GO

USE ElogicDB;
GO

IF OBJECT_ID('dbo.Projects', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Projects(
        Id UNIQUEIDENTIFIER NOT NULL 
            CONSTRAINT DF_Projects_Id DEFAULT NEWID(),

        WorkspaceId UNIQUEIDENTIFIER NOT NULL,
        Name NVARCHAR(150) NOT NULL,
        Description NVARCHAR(1000) NULL,

        Status NVARCHAR(50) NOT NULL 
            CONSTRAINT DF_Projects_Status DEFAULT ('A'),

        CreatedBy UNIQUEIDENTIFIER NOT NULL,

        CreatedAt DATETIME2(7) NOT NULL 
            CONSTRAINT DF_Projects_CreatedAt DEFAULT GETDATE(),

        UpdatedAt DATETIME2(7) NULL,

        CONSTRAINT PK_Projects PRIMARY KEY CLUSTERED (Id)
    );
END
GO

IF OBJECT_ID('dbo.Roles', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Roles(
        Id INT IDENTITY(1,1) NOT NULL,
        Name NVARCHAR(50) NOT NULL,
        Description NVARCHAR(250) NULL,

        CONSTRAINT PK_Roles PRIMARY KEY (Id),
        CONSTRAINT UQ_Roles_Name UNIQUE (Name)
    );
END
GO

IF OBJECT_ID('dbo.Users', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Users(
        Id UNIQUEIDENTIFIER NOT NULL 
            CONSTRAINT DF_Users_Id DEFAULT NEWID(),

        Email NVARCHAR(150) NOT NULL,
        Password NVARCHAR(500) NOT NULL,
        FullName NVARCHAR(150) NOT NULL,

        IsActive BIT NOT NULL 
            CONSTRAINT DF_Users_IsActive DEFAULT (1),

        CreatedAt DATETIME2(7) NOT NULL 
            CONSTRAINT DF_Users_CreatedAt DEFAULT GETDATE(),

        CONSTRAINT PK_Users PRIMARY KEY (Id),
        CONSTRAINT UQ_Users_Email UNIQUE (Email)
    );
END
GO

IF OBJECT_ID('dbo.Workspaces', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Workspaces(
        Id UNIQUEIDENTIFIER NOT NULL 
            CONSTRAINT DF_Workspaces_Id DEFAULT NEWID(),

        Name NVARCHAR(150) NOT NULL,
        Description NVARCHAR(500) NULL,

        IsActive BIT NOT NULL 
            CONSTRAINT DF_Workspaces_IsActive DEFAULT (1),

        CreatedAt DATETIME2(7) NOT NULL 
            CONSTRAINT DF_Workspaces_CreatedAt DEFAULT GETDATE(),

        CONSTRAINT PK_Workspaces PRIMARY KEY (Id)
    );
END
GO

IF OBJECT_ID('dbo.UserWorkspaceRoles', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.UserWorkspaceRoles(
        UserId UNIQUEIDENTIFIER NOT NULL,
        WorkspaceId UNIQUEIDENTIFIER NOT NULL,
        RoleId INT NOT NULL,

        AssignedAt DATETIME2(7) NOT NULL 
            CONSTRAINT DF_UserWorkspaceRoles_AssignedAt DEFAULT GETDATE(),

        CONSTRAINT PK_UserWorkspaceRoles PRIMARY KEY (UserId, WorkspaceId)
    );
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_Projects_WorkspaceId'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Projects_WorkspaceId
    ON dbo.Projects (WorkspaceId);
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_Users_Email'
)
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX IX_Users_Email
    ON dbo.Users (Email);
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_UserWorkspaceRoles_WorkspaceId'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_UserWorkspaceRoles_WorkspaceId
    ON dbo.UserWorkspaceRoles (WorkspaceId);
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_Projects_Users'
)
BEGIN
    ALTER TABLE dbo.Projects
    ADD CONSTRAINT FK_Projects_Users
    FOREIGN KEY (CreatedBy) REFERENCES dbo.Users(Id);
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_Projects_Workspaces'
)
BEGIN
    ALTER TABLE dbo.Projects
    ADD CONSTRAINT FK_Projects_Workspaces
    FOREIGN KEY (WorkspaceId) REFERENCES dbo.Workspaces(Id);
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_UWR_Roles'
)
BEGIN
    ALTER TABLE dbo.UserWorkspaceRoles
    ADD CONSTRAINT FK_UWR_Roles
    FOREIGN KEY (RoleId) REFERENCES dbo.Roles(Id);
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_UWR_Users'
)
BEGIN
    ALTER TABLE dbo.UserWorkspaceRoles
    ADD CONSTRAINT FK_UWR_Users
    FOREIGN KEY (UserId) REFERENCES dbo.Users(Id);
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_UWR_Workspaces'
)
BEGIN
    ALTER TABLE dbo.UserWorkspaceRoles
    ADD CONSTRAINT FK_UWR_Workspaces
    FOREIGN KEY (WorkspaceId) REFERENCES dbo.Workspaces(Id);
END
GO

IF OBJECT_ID('dbo.Auth_GetUserWorkspaces', 'P') IS NULL
EXEC('
CREATE PROCEDURE dbo.Auth_GetUserWorkspaces
(
    @UserId UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        w.Id AS WorkspaceId,
        w.Name AS WorkspaceName,
        r.Name AS Role
    FROM dbo.UserWorkspaceRoles uwr
        INNER JOIN dbo.Workspaces w
            ON w.Id = uwr.WorkspaceId
        INNER JOIN dbo.Roles r
            ON r.Id = uwr.RoleId
    WHERE uwr.UserId = @UserId
      AND w.IsActive = 1
    ORDER BY w.Name;
END
');
GO

IF OBJECT_ID('dbo.Auth_GetWorkspaceAccess', 'P') IS NULL
EXEC('
CREATE PROCEDURE dbo.Auth_GetWorkspaceAccess
(
    @UserId UNIQUEIDENTIFIER,
    @WorkspaceId UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 1
        uwr.UserId,
        uwr.WorkspaceId,
        r.Name AS Role
    FROM dbo.UserWorkspaceRoles uwr
        INNER JOIN dbo.Roles r
            ON r.Id = uwr.RoleId
    WHERE uwr.UserId = @UserId
      AND uwr.WorkspaceId = @WorkspaceId;
END
');
GO

IF OBJECT_ID('dbo.Auth_Login', 'P') IS NULL
EXEC('
CREATE PROCEDURE dbo.Auth_Login
(
    @Email NVARCHAR(150)
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Id,
        Email,
        Password,
        FullName,
        IsActive,
        CreatedAt
    FROM dbo.Users
    WHERE Email = @Email
      AND IsActive = 1;
END
');
GO

IF OBJECT_ID('dbo.Projects_Create', 'P') IS NULL
EXEC('
CREATE PROCEDURE dbo.Projects_Create
(
    @WorkspaceId UNIQUEIDENTIFIER,
    @Name NVARCHAR(150),
    @Description NVARCHAR(1000),
    @CreatedBy UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ProjectId UNIQUEIDENTIFIER = NEWID();

    INSERT INTO dbo.Projects
    (
        Id,
        WorkspaceId,
        Name,
        Description,
        Status,
        CreatedBy,
        CreatedAt
    )
    VALUES
    (
        @ProjectId,
        @WorkspaceId,
        @Name,
        @Description,
        ''A'',
        @CreatedBy,
        GETDATE()
    );

    SELECT
        Id,
        WorkspaceId,
        Name,
        Description,
        Status,
        CreatedBy,
        CreatedAt
    FROM dbo.Projects
    WHERE Id = @ProjectId;
END
');
GO

IF OBJECT_ID('dbo.Projects_GetById', 'P') IS NULL
EXEC('
CREATE PROCEDURE dbo.Projects_GetById
(
    @ProjectId UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.Id,
        p.WorkspaceId,
        p.Name,
        p.Description,
        p.Status,
        p.CreatedBy,
        u.FullName AS CreatedByName,
        p.CreatedAt,
        p.UpdatedAt
    FROM dbo.Projects p
        INNER JOIN dbo.Users u
            ON u.Id = p.CreatedBy
    WHERE p.Id = @ProjectId;
END
');
GO

IF OBJECT_ID('dbo.Projects_GetByWorkspace', 'P') IS NULL
EXEC('
CREATE PROCEDURE dbo.Projects_GetByWorkspace
(
    @WorkspaceId UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.Id,
        p.WorkspaceId,
        p.Name,
        p.Description,
        p.Status,
        p.CreatedBy,
        u.FullName AS CreatedByName,
        p.CreatedAt,
        p.UpdatedAt
    FROM dbo.Projects p
        INNER JOIN dbo.Users u
            ON u.Id = p.CreatedBy
    WHERE p.WorkspaceId = @WorkspaceId
    ORDER BY p.CreatedAt DESC;
END
');
GO

IF OBJECT_ID('dbo.Projects_Update', 'P') IS NULL
EXEC('
CREATE PROCEDURE dbo.Projects_Update
(
    @ProjectId UNIQUEIDENTIFIER,
    @Name NVARCHAR(150),
    @Description NVARCHAR(1000),
    @Status NVARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Projects
    SET
        Name = @Name,
        Description = @Description,
        Status = @Status,
        UpdatedAt = GETDATE()
    WHERE Id = @ProjectId;

    SELECT
        Id,
        WorkspaceId,
        Name,
        Description,
        Status,
        CreatedBy,
        CreatedAt,
        UpdatedAt
    FROM dbo.Projects
    WHERE Id = @ProjectId;
END
');
GO

IF NOT EXISTS (
    SELECT 1
    FROM dbo.Roles
    WHERE Name = 'Admin'
)
BEGIN
    INSERT INTO dbo.Roles (Name, Description)
    VALUES
    ('Admin', 'Administrator'),
    ('Editor', 'Editor manager'),
    ('Reader', 'Read/Write user');
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM dbo.Users
    WHERE Email = 'admin@elogic.com'
)
BEGIN
    DECLARE @AdminId UNIQUEIDENTIFIER = NEWID();
    DECLARE @EditorId UNIQUEIDENTIFIER = NEWID();
    DECLARE @ReaderId UNIQUEIDENTIFIER = NEWID();

    INSERT INTO dbo.Users (Id, Email, Password, FullName, IsActive)
    VALUES
    (@AdminId, 'admin@elogic.com', '$2a$11$k0Llcn1gD/CjdHTQ.shNBOPrtG9v7zxztn5YhbBBYPW3dyJ9/gHzq', 'Admin User', 1),
    (@EditorId, 'user@elogic.com', '$2a$11$k0Llcn1gD/CjdHTQ.shNBOPrtG9v7zxztn5YhbBBYPW3dyJ9/gHzq', 'Manager User', 1),
    (@ReaderId, 'reader@elogic.com', '$2a$11$k0Llcn1gD/CjdHTQ.shNBOPrtG9v7zxztn5YhbBBYPW3dyJ9/gHzq', 'Member User', 1);
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM dbo.Workspaces
    WHERE Name = 'Workspace alfa'
)
BEGIN
    DECLARE @DevWs UNIQUEIDENTIFIER = NEWID();
    DECLARE @OpsWs UNIQUEIDENTIFIER = NEWID();

    INSERT INTO dbo.Workspaces (Id, Name, Description, IsActive)
    VALUES
    (@DevWs, 'Workspace alfa', 'Operations workspace', 1),
    (@OpsWs, 'Workspace beta', 'Development workspace', 1);
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM dbo.UserWorkspaceRoles
)
BEGIN
    DECLARE @AdminRole INT = (SELECT Id FROM dbo.Roles WHERE Name = 'Admin');
    DECLARE @EditorRole INT = (SELECT Id FROM dbo.Roles WHERE Name = 'Editor');
    DECLARE @ReaderRole INT = (SELECT Id FROM dbo.Roles WHERE Name = 'Reader');

    DECLARE @AdminUser UNIQUEIDENTIFIER = (SELECT Id FROM dbo.Users WHERE Email = 'admin@elogic.com');
    DECLARE @EditorUser UNIQUEIDENTIFIER = (SELECT Id FROM dbo.Users WHERE Email = 'user@elogic.com');
    DECLARE @ReaderUser UNIQUEIDENTIFIER = (SELECT Id FROM dbo.Users WHERE Email = 'reader@elogic.com');

    DECLARE @OpsWorkspace UNIQUEIDENTIFIER = (SELECT Id FROM dbo.Workspaces WHERE Name = 'Workspace alfa');
    DECLARE @DevWorkspace UNIQUEIDENTIFIER = (SELECT Id FROM dbo.Workspaces WHERE Name = 'Workspace beta');

    INSERT INTO dbo.UserWorkspaceRoles (UserId, WorkspaceId, RoleId)
    VALUES
    (@AdminUser, @DevWorkspace, @AdminRole),
    (@AdminUser, @OpsWorkspace, @AdminRole),
    (@EditorUser, @DevWorkspace, @EditorRole),
    (@ReaderUser, @DevWorkspace, @ReaderRole);
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM dbo.Projects
    WHERE Name = 'Elogic API'
)
BEGIN
    DECLARE @AdminUser UNIQUEIDENTIFIER =
    (
        SELECT Id
        FROM dbo.Users
        WHERE Email = 'admin@elogic.com'
    );

    DECLARE @DevWorkspace UNIQUEIDENTIFIER =
    (
        SELECT Id
        FROM dbo.Workspaces
        WHERE Name = 'Workspace beta'
    );

    INSERT INTO dbo.Projects (WorkspaceId, Name, Description, Status, CreatedBy)
    VALUES
    (@DevWorkspace, 'Elogic API', 'API principal del sistema', 'A', @AdminUser),
    (@DevWorkspace, 'Elogic Frontend', 'Frontend Angular', 'A', @AdminUser),
    (@DevWorkspace, 'Authentication Module', 'Auth system', 'I', @AdminUser);
END
GO