CREATE TABLE [dbo].[refCountyCrim] (
    [CountyCrimID] INT           IDENTITY (1, 1) NOT NULL,
    [CountyCrim]   NVARCHAR (50) NULL,
    CONSTRAINT [PK_refCountyCrim] PRIMARY KEY CLUSTERED ([CountyCrimID] ASC) WITH (FILLFACTOR = 50)
);

