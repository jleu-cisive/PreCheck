CREATE TABLE [dbo].[Iris_Researcher_Avg_Turnaround] (
    [Id]                INT      IDENTITY (1, 1) NOT NULL,
    [R_ID]              INT      NULL,
    [AverageTurnAround] SMALLINT NULL,
    [InsertDate]        DATETIME NULL,
    CONSTRAINT [PK_Iris_Researcher_Avg_Turnaround] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE NONCLUSTERED INDEX [IX_R_ID]
    ON [dbo].[Iris_Researcher_Avg_Turnaround]([R_ID] ASC)
    INCLUDE([AverageTurnAround]) WITH (FILLFACTOR = 50)
    ON [FG_INDEX];

