CREATE TABLE [dbo].[ReportUploadLog] (
    [ReportUploadLogId]    INT      IDENTITY (1, 1) NOT NULL,
    [ReportID]             INT      NULL,
    [Resend]               BIT      CONSTRAINT [DF_ReportUploadLog_Resend] DEFAULT ((0)) NOT NULL,
    [ReportType]           INT      NULL,
    [ReportUploadVolumeID] INT      NULL,
    [CreatedDate]          DATETIME NULL,
    [CLNO]                 INT      NULL,
    CONSTRAINT [PK_ReportUploadLog] PRIMARY KEY CLUSTERED ([ReportUploadLogId] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE NONCLUSTERED INDEX [IX_REPORTUPLOADLOG_REPORTID]
    ON [dbo].[ReportUploadLog]([ReportID] ASC)
    INCLUDE([Resend], [ReportType]) WITH (FILLFACTOR = 90)
    ON [FG_INDEX];

