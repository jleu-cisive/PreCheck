CREATE TABLE [dbo].[BulkReportUploader_Scheduler] (
    [SchedulerId]      INT           IDENTITY (1, 1) NOT NULL,
    [Clientid]         INT           NOT NULL,
    [ReportType]       VARCHAR (100) NOT NULL,
    [LastRunDate]      DATETIME      NULL,
    [NextRunDate]      DATETIME      NULL,
    [ConfigurationXml] XML           NOT NULL,
    [StoredProcedure]  VARCHAR (100) NOT NULL,
    [IsSuccessRun]     BIT           NULL,
    [CreatedDate]      DATETIME      NOT NULL,
    [ModifiedDate]     DATETIME      NULL,
    [CreatedBy]        VARCHAR (500) NOT NULL,
    [ModifiedBy]       VARCHAR (500) NULL,
    [IsActive]         BIT           DEFAULT ((1)) NULL,
    [ErrorCount]       INT           NULL,
    CONSTRAINT [PK_SchedulerId] PRIMARY KEY CLUSTERED ([SchedulerId] ASC) WITH (FILLFACTOR = 70)
);

