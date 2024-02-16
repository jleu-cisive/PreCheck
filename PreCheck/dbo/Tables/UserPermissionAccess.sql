CREATE TABLE [dbo].[UserPermissionAccess] (
    [refPermissionID] INT          NULL,
    [UserID]          VARCHAR (8)  NOT NULL,
    [FormOrTabName]   VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_UserPermissionAccess] PRIMARY KEY CLUSTERED ([UserID] ASC, [FormOrTabName] ASC) WITH (FILLFACTOR = 50)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to table, dbo.refPermission. ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserPermissionAccess', @level2type = N'COLUMN', @level2name = N'refPermissionID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to table, dbo.Users.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserPermissionAccess', @level2type = N'COLUMN', @level2name = N'UserID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The name used to identify the specific control. Primarily used in BIS3.FormUserPermission.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserPermissionAccess', @level2type = N'COLUMN', @level2name = N'FormOrTabName';

