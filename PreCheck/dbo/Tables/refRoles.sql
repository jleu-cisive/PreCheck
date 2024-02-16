CREATE TABLE [dbo].[refRoles] (
    [refRoleID]     INT            IDENTITY (1, 1) NOT NULL,
    [Name]          NVARCHAR (50)  NOT NULL,
    [Description]   NVARCHAR (100) NOT NULL,
    [WebStatusCode] INT            NULL,
    [IsActive]      BIT            NOT NULL,
    [CreateDate]    DATETIME       NOT NULL,
    [CreatedBy]     VARCHAR (20)   NOT NULL,
    [UpdateDate]    DATETIME       NOT NULL,
    [UpdatedBy]     VARCHAR (20)   NOT NULL,
    CONSTRAINT [PK_refRoles] PRIMARY KEY CLUSTERED ([refRoleID] ASC) WITH (FILLFACTOR = 70)
);

