CREATE TABLE [dbo].[QReport_BCK170323] (
    [QReportID]           INT            IDENTITY (1, 1) NOT NULL,
    [UserID]              VARCHAR (8)    NULL,
    [QueryDesc]           VARCHAR (300)  NULL,
    [Query]               VARCHAR (8000) NULL,
    [Datatype]            VARCHAR (300)  NULL,
    [ModCount]            INT            NULL,
    [ParameterNames]      VARCHAR (300)  NULL,
    [TimeEstimate]        VARCHAR (20)   NULL,
    [ReportDescription]   VARCHAR (MAX)  NULL,
    [LastChangeReason]    VARCHAR (200)  NOT NULL,
    [LastChangeRequestor] VARCHAR (100)  NOT NULL,
    [CreateDate]          DATETIME       NOT NULL,
    [CreateBy]            VARCHAR (20)   NOT NULL,
    [ModifyDate]          DATETIME       NOT NULL,
    [ModifyBy]            VARCHAR (20)   NOT NULL,
    [LastExecutionDate]   DATETIME2 (7)  NULL,
    [LastExecutedBy]      VARCHAR (8)    NULL
);

