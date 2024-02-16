CREATE TABLE [dbo].[Iris_OnlineDB_PATAR_History] (
    [ID]     INT          IDENTITY (1, 1) NOT NULL,
    [Crimid] INT          NULL,
    [DateIt] DATETIME     NULL,
    [UserId] VARCHAR (20) NULL,
    CONSTRAINT [PK_Iris_OnlineDB_PATAR_History] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 50)
);

