CREATE TABLE [dbo].[Integration_Verification_SourceCode] (
    [VerificationSourceCodeID] INT           IDENTITY (1, 1) NOT NULL,
    [VerificationSourceCode]   VARCHAR (10)  NULL,
    [SectionKeyID]             INT           NOT NULL,
    [refVerificationSource]    VARCHAR (10)  NOT NULL,
    [IsChecked]                BIT           CONSTRAINT [DF_Integration_Verification_CompanyCode_IsVerified] DEFAULT ((0)) NOT NULL,
    [DateTimStamp]             DATETIME      CONSTRAINT [DF_Integration_Verification_SourceCode_DateTimStamp] DEFAULT (getdate()) NULL,
    [SourceVerifyType]         VARCHAR (100) NULL,
    [SourceVerifyName]         VARCHAR (100) NULL,
    CONSTRAINT [PK_Integration_Verification_CompanyCode] PRIMARY KEY CLUSTERED ([VerificationSourceCodeID] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE NONCLUSTERED INDEX [IX_Integration_Verification_SourceCode_refVerificationSource_IsChecked]
    ON [dbo].[Integration_Verification_SourceCode]([refVerificationSource] ASC, [IsChecked] ASC)
    INCLUDE([VerificationSourceCodeID], [SectionKeyID], [SourceVerifyType], [SourceVerifyName]) WITH (FILLFACTOR = 95)
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [IDX_Integration_Verification_SourceCode_SectionKeyID_refVerificationSource_Inc]
    ON [dbo].[Integration_Verification_SourceCode]([SectionKeyID] ASC, [refVerificationSource] ASC)
    INCLUDE([VerificationSourceCode], [IsChecked], [SourceVerifyName]) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IDX_Integration_Verification_SourceCode_refVerificationSource_DateTimStamp]
    ON [dbo].[Integration_Verification_SourceCode]([refVerificationSource] ASC, [DateTimStamp] ASC)
    INCLUDE([SectionKeyID]) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [refVerificationSource_IsChecked_Includes]
    ON [dbo].[Integration_Verification_SourceCode]([refVerificationSource] ASC, [IsChecked] ASC)
    INCLUDE([VerificationSourceCodeID], [SectionKeyID]) WITH (FILLFACTOR = 100);

