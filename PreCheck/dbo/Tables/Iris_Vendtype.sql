CREATE TABLE [dbo].[Iris_Vendtype] (
    [id]       INT          IDENTITY (1, 1) NOT NULL,
    [Vendtype] VARCHAR (50) NULL,
    CONSTRAINT [PK_Iris_Vendtype] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 50)
);

