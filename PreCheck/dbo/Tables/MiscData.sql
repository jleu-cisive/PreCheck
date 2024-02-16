CREATE TABLE [dbo].[MiscData] (
    [MiscDataID]   INT            IDENTITY (1, 1) NOT NULL,
    [AmendComment] VARCHAR (2000) NULL,
    CONSTRAINT [PK_MiscData] PRIMARY KEY CLUSTERED ([MiscDataID] ASC) WITH (FILLFACTOR = 50)
);

