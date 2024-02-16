CREATE TABLE [dbo].[VersionHistory] (
    [VersionHistoryID] INT           IDENTITY (1, 1) NOT NULL,
    [Application]      VARCHAR (100) NOT NULL,
    [Major]            INT           NOT NULL,
    [Minor]            INT           NOT NULL,
    [Build]            INT           NOT NULL,
    [Updated]          DATETIME      NOT NULL,
    CONSTRAINT [PK_VersionHistory] PRIMARY KEY CLUSTERED ([VersionHistoryID] ASC) WITH (FILLFACTOR = 50)
);

