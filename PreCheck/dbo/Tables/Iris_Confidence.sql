CREATE TABLE [dbo].[Iris_Confidence] (
    [id]         INT          IDENTITY (1, 1) NOT NULL,
    [Confidence] VARCHAR (50) NULL,
    CONSTRAINT [PK_Iris_Confidence] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 50)
);

