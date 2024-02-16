CREATE TABLE [dbo].[BRSources] (
    [SourceID] INT           IDENTITY (1, 1) NOT NULL,
    [Source]   NVARCHAR (25) NOT NULL,
    CONSTRAINT [PK_BRSources] PRIMARY KEY CLUSTERED ([SourceID] ASC) WITH (FILLFACTOR = 50)
);

