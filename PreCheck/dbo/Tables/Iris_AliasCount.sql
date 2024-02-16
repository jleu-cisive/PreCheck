CREATE TABLE [dbo].[Iris_AliasCount] (
    [id]         INT         IDENTITY (1, 1) NOT NULL,
    [Aliascount] VARCHAR (5) NULL,
    CONSTRAINT [PK_Iris_AliasCount] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 50)
);

