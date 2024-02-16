CREATE TABLE [dbo].[ClientRoles] (
    [ClientRoleID] INT            NOT NULL,
    [RoleName]     NVARCHAR (50)  NOT NULL,
    [Description]  NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_ClientRoles] PRIMARY KEY CLUSTERED ([ClientRoleID] ASC) WITH (FILLFACTOR = 90)
) TEXTIMAGE_ON [PRIMARY];

