CREATE TABLE [dbo].[VerificationBusinessRuleGroup] (
    [GroupID]               INT          IDENTITY (1, 1) NOT NULL,
    [VerificationRuleGroup] INT          NULL,
    [IsActive]              TINYINT      NULL,
    [VerificationType]      VARCHAR (20) NULL,
    [ElseBlurb]             INT          NULL,
    [BlurbID]               INT          NULL,
    [IsElse]                BIT          NULL,
    [IsVerified]            BIT          NULL,
    [InvoiceCreating]       BIT          NULL,
    [ExecutionOrder]        INT          NULL,
    CONSTRAINT [PK_VerificationBusinessRuleGroup] PRIMARY KEY CLUSTERED ([GroupID] ASC) WITH (FILLFACTOR = 50)
);

