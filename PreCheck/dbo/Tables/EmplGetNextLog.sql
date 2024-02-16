CREATE TABLE [dbo].[EmplGetNextLog] (
    [EmplGetNextLogID] INT          IDENTITY (1, 1) NOT NULL,
    [APNO]             INT          NULL,
    [EmplID]           INT          NULL,
    [UserID]           VARCHAR (8)  NULL,
    [QueueType]        VARCHAR (50) NULL,
    [AppEntryDate]     DATETIME     NULL,
    [AppExitDate]      DATETIME     NULL,
    CONSTRAINT [PK_EmplGetNextLog] PRIMARY KEY CLUSTERED ([EmplGetNextLogID] ASC) WITH (FILLFACTOR = 50)
);

