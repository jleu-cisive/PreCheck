CREATE TABLE [dbo].[WinServiceSuccessLog] (
    [WinServiceSuccessLogID] INT          IDENTITY (1, 1) NOT NULL,
    [ServiceName]            VARCHAR (50) NULL,
    [RunDate]                DATETIME     CONSTRAINT [DF_WinServiceSuccessLog_RunDate] DEFAULT (getdate()) NULL,
    [Success]                BIT          NULL,
    [CLNO]                   INT          NULL,
    CONSTRAINT [PK_WinServiceSuccessLog] PRIMARY KEY CLUSTERED ([WinServiceSuccessLogID] ASC) WITH (FILLFACTOR = 50)
);

