CREATE TABLE [Stage].[ApplFinalAdjudicationLog] (
    [ApplFinalAdjudicationLogId] INT          IDENTITY (1, 1) NOT NULL,
    [APNO]                       INT          NOT NULL,
    [OverallStatus]              INT          NOT NULL,
    [CreateDate]                 DATETIME     CONSTRAINT [DF_ApplFinalAdjudicationLog_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreateBy]                   VARCHAR (50) NOT NULL,
    [ModifyDate]                 DATETIME     CONSTRAINT [DF_ApplFinalAdjudicationLog_ModifyDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ApplFinalAdjudicationLog] PRIMARY KEY CLUSTERED ([ApplFinalAdjudicationLogId] ASC)
);

