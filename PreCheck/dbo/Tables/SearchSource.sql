CREATE TABLE [dbo].[SearchSource] (
    [SearchSourceID]   TINYINT      NOT NULL,
    [SearchSourceDesc] VARCHAR (30) NOT NULL,
    CONSTRAINT [PK_SearchSource] PRIMARY KEY CLUSTERED ([SearchSourceID] ASC) WITH (FILLFACTOR = 50)
);

