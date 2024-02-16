CREATE TABLE [dbo].[PendingCrimsLog] (
    [PendingLogID]       INT          IDENTITY (1, 1) NOT NULL,
    [CrimID]             INT          NULL,
    [APNO]               INT          NULL,
    [OriginalCrimStatus] VARCHAR (10) NULL,
    [ResolvedStatus]     VARCHAR (10) NULL,
    [StartTime]          DATETIME     NULL,
    [EndTime]            DATETIME     NULL,
    [TimeSpent]          INT          NULL,
    [ResolvedBy]         VARCHAR (50) NULL,
    CONSTRAINT [PK_PendingCrimsLog] PRIMARY KEY CLUSTERED ([PendingLogID] ASC) WITH (FILLFACTOR = 50)
);

