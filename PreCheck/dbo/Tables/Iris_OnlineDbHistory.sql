CREATE TABLE [dbo].[Iris_OnlineDbHistory] (
    [ID]         INT          IDENTITY (1, 1) NOT NULL,
    [IrisPhase]  VARCHAR (50) NULL,
    [PhaseValue] VARCHAR (50) NULL,
    [Crimid]     INT          NULL,
    [DateIt]     DATETIME     NULL,
    [UserId]     VARCHAR (50) NULL,
    CONSTRAINT [PK_IrisOnlineDbHistory] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 50)
);

