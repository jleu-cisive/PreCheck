CREATE TABLE [dbo].[QReportRequest] (
    [QReportRequestID] INT            IDENTITY (1, 1) NOT NULL,
    [QueryName]        VARCHAR (250)  NULL,
    [Parameters]       VARCHAR (300)  NULL,
    [Description]      VARCHAR (1500) NULL,
    [UserID]           VARCHAR (8)    NULL,
    [CreatedDate]      DATETIME       NULL,
    [NeededBy]         DATETIME       NULL,
    [Completed]        BIT            NULL,
    [CompletedDate]    DATETIME       NULL,
    CONSTRAINT [PK_QReportRequest] PRIMARY KEY CLUSTERED ([QReportRequestID] ASC) WITH (FILLFACTOR = 50)
);

