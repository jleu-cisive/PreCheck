CREATE TABLE [dbo].[ReferenceProLog] (
    [Id]        INT            IDENTITY (1, 1) NOT NULL,
    [SectionId] INT            NULL,
    [Apno]      INT            NULL,
    [Data]      VARCHAR (1000) NULL,
    [LogDate]   DATETIME       NULL,
    CONSTRAINT [PK_ReferenceProLog] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 50)
);

