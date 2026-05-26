/*==========================================================
CREATE DATABASE
==========================================================*/
IF DB_ID('ElogicDB') IS NULL
BEGIN
    CREATE DATABASE ElogicDB;
END
GO

USE ElogicDB;
GO


/*==========================================================
TABLES
==========================================================*/

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
GO


CREATE TABLE dbo.Roles(
    Id INT IDENTITY(1,1) NOT NULL,
    Name NVARCHAR(50) NOT NULL,
    Description NVARCHAR(250) NULL,

    CONSTRAINT PK_Roles PRIMARY KEY (Id),
    CONSTRAINT UQ_Roles_Name UNIQUE (Name)
);
GO


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
GO


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
GO


CREATE TABLE dbo.UserWorkspaceRoles(
    UserId UNIQUEIDENTIFIER NOT NULL,
    WorkspaceId UNIQUEIDENTIFIER NOT NULL,
    RoleId INT NOT NULL,

    AssignedAt DATETIME2(7) NOT NULL 
        CONSTRAINT DF_UserWorkspaceRoles_AssignedAt DEFAULT GETDATE(),

    CONSTRAINT PK_UserWorkspaceRoles PRIMARY KEY (UserId, WorkspaceId)
);
GO


/*==========================================================
INDEXES
==========================================================*/

CREATE NONCLUSTERED INDEX IX_Projects_WorkspaceId
ON dbo.Projects (WorkspaceId);
GO

CREATE UNIQUE NONCLUSTERED INDEX IX_Users_Email
ON dbo.Users (Email);
GO

CREATE NONCLUSTERED INDEX IX_UserWorkspaceRoles_WorkspaceId
ON dbo.UserWorkspaceRoles (WorkspaceId);
GO


/*==========================================================
FOREIGN KEYS
==========================================================*/

ALTER TABLE dbo.Projects
ADD CONSTRAINT FK_Projects_Users
FOREIGN KEY (CreatedBy) REFERENCES dbo.Users(Id);
GO

ALTER TABLE dbo.Projects
ADD CONSTRAINT FK_Projects_Workspaces
FOREIGN KEY (WorkspaceId) REFERENCES dbo.Workspaces(Id);
GO

ALTER TABLE dbo.UserWorkspaceRoles
ADD CONSTRAINT FK_UWR_Roles
FOREIGN KEY (RoleId) REFERENCES dbo.Roles(Id);
GO

ALTER TABLE dbo.UserWorkspaceRoles
ADD CONSTRAINT FK_UWR_Users
FOREIGN KEY (UserId) REFERENCES dbo.Users(Id);
GO

ALTER TABLE dbo.UserWorkspaceRoles
ADD CONSTRAINT FK_UWR_Workspaces
FOREIGN KEY (WorkspaceId) REFERENCES dbo.Workspaces(Id);
GO


/*==========================================================
ROLES SEED
==========================================================*/

INSERT INTO dbo.Roles (Name, Description)
VALUES
('Admin', 'Administrator'),
('Editor', 'Editor manager'),
('Reader', 'Read/Write user');
GO


DECLARE @AdminId UNIQUEIDENTIFIER = NEWID();
DECLARE @EditorId UNIQUEIDENTIFIER = NEWID();
DECLARE @ReaderId UNIQUEIDENTIFIER = NEWID();

INSERT INTO dbo.Users (Id, Email, Password, FullName, IsActive)
VALUES
(@AdminId, 'admin@elogic.com',  '$2a$11$k0Llcn1gD/CjdHTQ.shNBOPrtG9v7zxztn5YhbBBYPW3dyJ9/gHzq', 'Admin User', 1),
(@ManagerId, 'user@elogic.com',  '$2a$11$k0Llcn1gD/CjdHTQ.shNBOPrtG9v7zxztn5YhbBBYPW3dyJ9/gHzq', 'Manager User', 1),
(@MemberId, 'reader@elogic.com', '$2a$11$k0Llcn1gD/CjdHTQ.shNBOPrtG9v7zxztn5YhbBBYPW3dyJ9/gHzq', 'Member User', 1);
GO


/*==========================================================
WORKSPACES SEED
==========================================================*/

DECLARE @DevWs UNIQUEIDENTIFIER = NEWID();
DECLARE @OpsWs UNIQUEIDENTIFIER = NEWID();

INSERT INTO dbo.Workspaces (Id, Name, Description, IsActive)
VALUES
(@DevWs, 'Workspace alfa', 'Operations workspace', 1),
(@OpsWs, 'Workspace beta', 'Development workspace', 1);
GO


/*==========================================================
ROLE IDS
==========================================================*/

DECLARE @AdminRole INT = (SELECT Id FROM dbo.Roles WHERE Name = 'Admin');
DECLARE @EditorRole INT = (SELECT Id FROM dbo.Roles WHERE Name = 'Editor');
DECLARE @ReaderRole INT = (SELECT Id FROM dbo.Roles WHERE Name = 'Reader');

DECLARE @AdminUser UNIQUEIDENTIFIER = (SELECT Id FROM dbo.Users WHERE Email = 'admin@elogic.com');
DECLARE @EditorUser UNIQUEIDENTIFIER = (SELECT Id FROM dbo.Users WHERE Email = 'user@elogic.com');
DECLARE @ReaderUser UNIQUEIDENTIFIER = (SELECT Id FROM dbo.Users WHERE Email = 'reader@elogic.com');

DECLARE @OpsWorkspace  UNIQUEIDENTIFIER = (SELECT Id FROM dbo.Workspaces WHERE Name = 'Workspace alfa');
DECLARE @DevWorkspace UNIQUEIDENTIFIER = (SELECT Id FROM dbo.Workspaces WHERE Name = 'Workspace beta');
GO


/*==========================================================
USER WORKSPACE ROLES
==========================================================*/

INSERT INTO dbo.UserWorkspaceRoles (UserId, WorkspaceId, RoleId)
VALUES
(@AdminUser, @DevWorkspace, @AdminRole),
(@AdminUser, @OpsWorkspace, @AdminRole),
(@EditorUser, @DevWorkspace, @EditorRole),
(@ReaderUser, @DevWorkspace, @ReaderRole);
GO


/*==========================================================
PROJECTS SEED
==========================================================*/

INSERT INTO dbo.Projects (WorkspaceId, Name, Description, Status, CreatedBy)
VALUES
(@DevWorkspace, 'Elogic API', 'API principal del sistema', 'A', @AdminUser),
(@DevWorkspace, 'Elogic Frontend', 'Frontend Angular', 'A', @AdminUser),
(@DevWorkspace, 'Authentication Module', 'Auth system', 'I', @AdminUser);
GO