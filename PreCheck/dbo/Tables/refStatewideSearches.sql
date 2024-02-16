CREATE TABLE [dbo].[refStatewideSearches] (
    [StatewideSearchID] INT           IDENTITY (1, 1) NOT NULL,
    [Description]       NVARCHAR (50) NULL,
    CONSTRAINT [PK_refStatewideSearch] PRIMARY KEY CLUSTERED ([StatewideSearchID] ASC) WITH (FILLFACTOR = 50)
);

