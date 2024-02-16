CREATE TABLE [dbo].[ApplGetNextLog] (
    [ApplGetNextLogID] INT          IDENTITY (1, 1) NOT NULL,
    [APNO]             INT          NULL,
    [username]         VARCHAR (8)  NULL,
    [QueueType]        VARCHAR (20) NULL,
    [CreatedDate]      DATETIME     NULL,
    CONSTRAINT [PK_ApplGetNextLog] PRIMARY KEY CLUSTERED ([ApplGetNextLogID] ASC) WITH (FILLFACTOR = 50)
);

