CREATE TABLE [dbo].[Iris_Avg_Turnaround] (
    [id]            INT          IDENTITY (1, 1) NOT NULL,
    [Avgturnaround] VARCHAR (20) NULL,
    CONSTRAINT [PK_Iris_Avg_Turnaround] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 50)
);

