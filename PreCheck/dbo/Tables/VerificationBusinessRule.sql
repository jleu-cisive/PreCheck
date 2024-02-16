CREATE TABLE [dbo].[VerificationBusinessRule] (
    [VerificationBusinessRuleID]   INT           IDENTITY (1, 1) NOT NULL,
    [VerificationField]            VARCHAR (50)  NULL,
    [VerificationOperator]         VARCHAR (50)  NULL,
    [VerificationRule]             VARCHAR (100) NULL,
    [VerificationFieldType]        VARCHAR (10)  NULL,
    [VerificationRuleID]           INT           NOT NULL,
    [IsConstant]                   BIT           NULL,
    [AddValue]                     INT           NULL,
    [VerificationBusinessRuleType] VARCHAR (20)  NULL,
    CONSTRAINT [PK_VerificationBusinessRule] PRIMARY KEY CLUSTERED ([VerificationBusinessRuleID] ASC) WITH (FILLFACTOR = 50)
);

