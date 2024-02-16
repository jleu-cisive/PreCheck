CREATE TABLE [dbo].[ReleaseText] (
    [ReleaseTextID]     INT            IDENTITY (1, 1) NOT NULL,
    [ClientType]        VARCHAR (50)   NULL,
    [DisclosureText]    VARCHAR (MAX)  NULL,
    [AuthorizationText] VARCHAR (8000) NULL,
    [clno]              INT            NULL,
    [LastModifiedDate]  DATETIME       NULL,
    [ChangedBy]         VARCHAR (50)   NULL,
    CONSTRAINT [PK_ReleaseText] PRIMARY KEY CLUSTERED ([ReleaseTextID] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE NONCLUSTERED INDEX [IDX_ReleaseText_CLNO]
    ON [dbo].[ReleaseText]([clno] ASC)
    INCLUDE([ClientType]) WITH (FILLFACTOR = 70);

