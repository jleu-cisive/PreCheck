CREATE TABLE [dbo].[IRIS_ResultLogCategory] (
    [ResultLogCategoryID] INT          IDENTITY (1, 1) NOT NULL,
    [ResultLogCategory]   VARCHAR (20) NULL,
    CONSTRAINT [PK_IRIS_ResultLogCategory] PRIMARY KEY CLUSTERED ([ResultLogCategoryID] ASC) WITH (FILLFACTOR = 50)
);

