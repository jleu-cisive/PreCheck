CREATE TABLE [dbo].[Iris_Delivery] (
    [id]       INT          IDENTITY (1, 1) NOT NULL,
    [delivery] VARCHAR (50) NULL,
    CONSTRAINT [PK_Iris_Delivery] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 50)
);

