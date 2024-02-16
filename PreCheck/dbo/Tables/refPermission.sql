CREATE TABLE [dbo].[refPermission] (
    [refPermissionID] INT          IDENTITY (1, 1) NOT NULL,
    [Permission]      VARCHAR (50) NULL,
    [IsActive]        BIT          CONSTRAINT [DF_refPermission_IsActive] DEFAULT (1) NULL,
    CONSTRAINT [PK_refPermission] PRIMARY KEY CLUSTERED ([refPermissionID] ASC) WITH (FILLFACTOR = 50)
);

