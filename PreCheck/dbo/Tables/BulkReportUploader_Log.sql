CREATE TABLE [dbo].[BulkReportUploader_Log] (
    [LogId]       INT            IDENTITY (1, 1) NOT NULL,
    [Clientid]    INT            NOT NULL,
    [ReportType]  VARCHAR (100)  NOT NULL,
    [SchedulerId] INT            NOT NULL,
    [RunDate]     DATETIME       NOT NULL,
    [Status]      BIT            NULL,
    [Error]       VARCHAR (8000) NULL,
    [LogDate]     DATETIME       NOT NULL,
    CONSTRAINT [PK_LogId] PRIMARY KEY CLUSTERED ([LogId] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_SchedulerId] FOREIGN KEY ([SchedulerId]) REFERENCES [dbo].[BulkReportUploader_Scheduler] ([SchedulerId])
);

