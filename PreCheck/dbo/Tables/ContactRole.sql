CREATE TABLE [dbo].[ContactRole] (
    [ContactRoleID]         INT      IDENTITY (1, 1) NOT NULL,
    [ContactID]             INT      NOT NULL,
    [ContactType]           INT      NULL,
    [PC_ApplicationID]      INT      NOT NULL,
    [RoleID]                INT      NOT NULL,
    [CreatedDate]           DATETIME NOT NULL,
    [Deny_PC_ApplicationID] INT      NULL,
    CONSTRAINT [PK_ContactRole] PRIMARY KEY CLUSTERED ([ContactRoleID] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_UNI_ID_APP]
    ON [dbo].[ContactRole]([ContactID] ASC, [PC_ApplicationID] ASC) WITH (FILLFACTOR = 50)
    ON [FG_INDEX];

