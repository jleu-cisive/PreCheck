CREATE TABLE [dbo].[refBRSourcePriority] (
    [RefID]         INT IDENTITY (1, 1) NOT NULL,
    [ServiceTypeID] INT NOT NULL,
    [SourceID]      INT NOT NULL,
    [Priority]      INT NOT NULL,
    CONSTRAINT [PK_refBRSourcePriority] PRIMARY KEY CLUSTERED ([RefID] ASC) WITH (FILLFACTOR = 50),
    CONSTRAINT [FK_refBRSourcePriority_BRSources] FOREIGN KEY ([SourceID]) REFERENCES [dbo].[BRSources] ([SourceID]),
    CONSTRAINT [FK_refBRSourcePriority_refServiceType] FOREIGN KEY ([ServiceTypeID]) REFERENCES [dbo].[refServiceType] ([ServiceType])
);

