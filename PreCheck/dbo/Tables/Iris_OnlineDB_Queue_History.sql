CREATE TABLE [dbo].[Iris_OnlineDB_Queue_History] (
    [ID]         INT          IDENTITY (1, 1) NOT NULL,
    [IrisStage]  VARCHAR (50) NULL,
    [StageValue] VARCHAR (50) NULL,
    [Crimid]     INT          NULL,
    [DateIt]     DATETIME     NULL,
    [UserId]     VARCHAR (50) NULL,
    CONSTRAINT [PK_Iris_OnlineDB_Queue_History] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 50)
);

