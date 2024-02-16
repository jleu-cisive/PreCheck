CREATE TABLE [Stage].[ApplFinalAdjudicationSubLog] (
    [ApplFinalAdjudicationSubLogId] INT          IDENTITY (1, 1) NOT NULL,
    [ApplFinalAdjudicationLogId]    INT          NOT NULL,
    [ApplSection]                   VARCHAR (50) NOT NULL,
    [SectStat]                      VARCHAR (1)  NOT NULL,
    [SectSubStatusId]               INT          NULL,
    [CreateDate]                    DATETIME     CONSTRAINT [DF_ApplFinalAdjudicationSubLog_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreateBy]                      VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_ApplFinalAdjudicationSubLog] PRIMARY KEY CLUSTERED ([ApplFinalAdjudicationSubLogId] ASC)
);

