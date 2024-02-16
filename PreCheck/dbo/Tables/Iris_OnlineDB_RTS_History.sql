CREATE TABLE [dbo].[Iris_OnlineDB_RTS_History] (
    [ID]               INT          IDENTITY (1, 1) NOT NULL,
    [ReadytoSendValue] BIT          NULL,
    [CrimId]           INT          NULL,
    [DateIt]           DATETIME     NULL,
    [UserId]           VARCHAR (20) NULL,
    CONSTRAINT [PK_Iris_OnlineDB_RTS_History] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 50)
);

