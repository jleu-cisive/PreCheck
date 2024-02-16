CREATE TABLE [dbo].[Integration_Verification_Transaction] (
    [VerficationTransactionId] INT            IDENTITY (1, 1) NOT NULL,
    [VerificationDbId]         INT            NULL,
    [SSN]                      VARCHAR (11)   NOT NULL,
    [VerificationCodeId]       VARCHAR (50)   NULL,
    [CreatedBy]                VARCHAR (50)   NULL,
    [CreatedDate]              DATETIME       CONSTRAINT [DF_Integration_Verification_Transaction_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [VerifiedDate]             DATETIME       NULL,
    [RequestXML]               XML            NULL,
    [ResponseXML]              XML            NULL,
    [ErrorDetails]             VARCHAR (2000) NULL,
    [IsComplete]               BIT            CONSTRAINT [DF_Integration_Verification_Transaction_IsComplete] DEFAULT ((0)) NOT NULL,
    [VerificationCodeName]     VARCHAR (500)  NULL,
    [IsInternalVerification]   BIT            CONSTRAINT [DF_Integration_Verification_Transaction_IsVerifiedInternally] DEFAULT ((0)) NOT NULL,
    [DOB]                      VARCHAR (30)   NULL,
    [VerificationCodeIDType]   VARCHAR (30)   NULL,
    [VerificationOperation]    VARCHAR (100)  NULL,
    [apno]                     INT            NULL,
    [VendorId]                 INT            NULL,
    [IsPresent]                BIT            DEFAULT ((0)) NULL,
    [IsFoundEmployerCode]      BIT            DEFAULT (NULL) NULL,
    [AliasLogicStatus]         VARCHAR (100)  DEFAULT (NULL) NULL,
    [CodeStatus]               VARCHAR (2)    DEFAULT (NULL) NULL,
    CONSTRAINT [PK_Integration_Verification_Transaction] PRIMARY KEY CLUSTERED ([VerficationTransactionId] ASC) WITH (FILLFACTOR = 70, DATA_COMPRESSION = PAGE)
) TEXTIMAGE_ON [PRIMARY];


GO
CREATE NONCLUSTERED INDEX [IDX_Integration_Verification_Transaction_APNO_Inc]
    ON [dbo].[Integration_Verification_Transaction]([apno] ASC)
    INCLUDE([VerificationCodeId]) WITH (FILLFACTOR = 70)
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [IsComplete_VerificationCodeIDType_Includes]
    ON [dbo].[Integration_Verification_Transaction]([IsComplete] ASC, [VerificationCodeIDType] ASC)
    INCLUDE([SSN], [VerificationCodeId], [CreatedBy], [CreatedDate], [VerifiedDate], [ResponseXML], [apno], [VendorId], [IsPresent]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [IX_Integration_Verification_Transaction_CreatedDate]
    ON [dbo].[Integration_Verification_Transaction]([CreatedDate] ASC)
    INCLUDE([VerficationTransactionId]) WITH (FILLFACTOR = 95)
    ON [FG_INDEX];


GO
CREATE PRIMARY XML INDEX [PXML_Integration_Verif_Trans]
    ON [dbo].[Integration_Verification_Transaction]([ResponseXML])
    WITH (PAD_INDEX = OFF, FILLFACTOR = 70);


GO
CREATE XML INDEX [SXML_Integration_Verif_Trans_01]
    ON [dbo].[Integration_Verification_Transaction]([ResponseXML])
    USING XML INDEX [PXML_Integration_Verif_Trans] FOR PATH
    WITH (PAD_INDEX = OFF, FILLFACTOR = 70);


GO
CREATE XML INDEX [SXML_Integration_Verif_Trans_02]
    ON [dbo].[Integration_Verification_Transaction]([ResponseXML])
    USING XML INDEX [PXML_Integration_Verif_Trans] FOR VALUE
    WITH (PAD_INDEX = OFF, FILLFACTOR = 70);


GO
CREATE STATISTICS [_WA_Sys_00000004_74CFE6FB]
    ON [dbo].[Integration_Verification_Transaction]([VerificationCodeId]);


GO
CREATE STATISTICS [_WA_Sys_0000000C_74CFE6FB]
    ON [dbo].[Integration_Verification_Transaction]([VerificationCodeName]);


GO
CREATE STATISTICS [_WA_Sys_00000006_74CFE6FB]
    ON [dbo].[Integration_Verification_Transaction]([CreatedDate]);


GO
CREATE STATISTICS [_WA_Sys_00000012_74CFE6FB]
    ON [dbo].[Integration_Verification_Transaction]([VendorId]);


GO
CREATE STATISTICS [_WA_Sys_0000000A_74CFE6FB]
    ON [dbo].[Integration_Verification_Transaction]([ErrorDetails]);


GO
CREATE STATISTICS [_WA_Sys_00000014_74CFE6FB]
    ON [dbo].[Integration_Verification_Transaction]([IsFoundEmployerCode]);

