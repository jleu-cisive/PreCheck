CREATE TABLE [Compliance].[AdverseActionReason] (
    [APNO]                  INT          NOT NULL,
    [RuleGroup]             VARCHAR (25) NOT NULL,
    [SectionId]             INT          NULL,
    [SectionKeyId]          INT          NULL,
    [CreateBy]              VARCHAR (50) NOT NULL,
    [CreateDate]            DATETIME     NOT NULL,
    [ModifyBy]              VARCHAR (50) NOT NULL,
    [ModifyDate]            DATETIME     NOT NULL,
    [SectionName]           VARCHAR (25) NOT NULL,
    [AdverseActionReasonId] INT          IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_AdverseActionReason] PRIMARY KEY CLUSTERED ([AdverseActionReasonId] ASC) WITH (FILLFACTOR = 70)
);


GO
CREATE NONCLUSTERED INDEX [RuleGroup_SectionId_SectionKeyId]
    ON [Compliance].[AdverseActionReason]([RuleGroup] ASC, [SectionId] ASC, [SectionKeyId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [NCI_APNO]
    ON [Compliance].[AdverseActionReason]([APNO] ASC)
    INCLUDE([RuleGroup]);

