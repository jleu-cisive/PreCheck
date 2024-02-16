CREATE TABLE [dbo].[Iris_Payment] (
    [id]      INT          IDENTITY (1, 1) NOT NULL,
    [Payment] VARCHAR (50) NULL,
    CONSTRAINT [PK_Iris_Payment] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 50)
);

