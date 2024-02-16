CREATE TABLE [dbo].[WinServiceLog] (
    [WinServiceLogID] INT      IDENTITY (1, 1) NOT NULL,
    [LogDate]         DATETIME CONSTRAINT [DF_WinServiceLog_LogDate] DEFAULT (getdate()) NOT NULL,
    [LogMessage]      TEXT     NULL,
    CONSTRAINT [PK_WinServiceLog] PRIMARY KEY CLUSTERED ([WinServiceLogID] ASC) WITH (FILLFACTOR = 80)
) TEXTIMAGE_ON [PRIMARY];

