CREATE TABLE [dbo].[Partner_Log] (
    [Partner_LogId] INT           IDENTITY (1, 1) NOT NULL,
    [PartnerID]     INT           NULL,
    [Section]       VARCHAR (15)  NULL,
    [SectionID]     INT           NULL,
    [ApplAliasID]   INT           NULL,
    [Request]       VARCHAR (MAX) NULL,
    [Response]      VARCHAR (MAX) NULL,
    [Status]        INT           NULL,
    [CreatedDate]   DATETIME      NULL,
    CONSTRAINT [PK_Partner_Log] PRIMARY KEY CLUSTERED ([Partner_LogId] ASC) WITH (FILLFACTOR = 70)
);


GO
CREATE NONCLUSTERED INDEX [IX_Partner_Log_SectionID]
    ON [dbo].[Partner_Log]([SectionID] ASC)
    INCLUDE([ApplAliasID]);

