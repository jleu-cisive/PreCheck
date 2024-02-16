CREATE TABLE [dbo].[VerificationRuleGroupDetail] (
    [VerificationRuleGroupDetailID] INT          IDENTITY (1, 1) NOT NULL,
    [VerificationRuleGroupID]       INT          NULL,
    [VerificationRuleID]            INT          NULL,
    [VerificationType]              VARCHAR (50) NULL,
    [IsActive]                      TINYINT      NULL,
    CONSTRAINT [PK_VerificationRuleGroupDetail] PRIMARY KEY CLUSTERED ([VerificationRuleGroupDetailID] ASC)
);

