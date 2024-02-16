CREATE TABLE [dbo].[WinServiceSchedule] (
    [WinServiceScheduleID]  INT           IDENTITY (1, 1) NOT NULL,
    [ServiceName]           VARCHAR (50)  NULL,
    [ServiceTimeStart]      DATETIME      NULL,
    [ServiceActive]         BIT           NULL,
    [ServiceNextRunTime]    DATETIME      NULL,
    [ServiceType]           VARCHAR (50)  NULL,
    [ServiceTimeValue]      INT           NULL,
    [ServiceRetryRunTime]   DATETIME      NULL,
    [ServiceRetryType]      VARCHAR (50)  NULL,
    [ServiceRetryTimeValue] INT           NULL,
    [AllowThreading]        BIT           NULL,
    [ServerName]            VARCHAR (50)  NULL,
    [ServiceDescription]    VARCHAR (255) NULL,
    CONSTRAINT [PK_WinServiceScheduleID] PRIMARY KEY CLUSTERED ([WinServiceScheduleID] ASC) WITH (FILLFACTOR = 50)
);

