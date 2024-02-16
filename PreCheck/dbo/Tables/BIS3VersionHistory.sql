CREATE TABLE [dbo].[BIS3VersionHistory] (
    [BIS3VersionHistoryID] INT           IDENTITY (1, 1) NOT NULL,
    [Version]              VARCHAR (50)  NULL,
    [Comments]             VARCHAR (500) NULL,
    [VersionDate]          DATETIME      NULL,
    CONSTRAINT [PK_BIS3VersionHistory] PRIMARY KEY CLUSTERED ([BIS3VersionHistoryID] ASC) WITH (FILLFACTOR = 50)
);

