CREATE TABLE [dbo].[Integration_Verification_AliasList] (
    [AliasListId]      INT            IDENTITY (1, 1) NOT NULL,
    [VerificationCode] INT            NULL,
    [VerificationName] VARCHAR (500)  NULL,
    [APNO]             INT            DEFAULT (NULL) NULL,
    [SSN]              VARCHAR (11)   DEFAULT (NULL) NULL,
    [SourceFound]      VARCHAR (1000) NULL,
    CONSTRAINT [PK_Integration_Verification_AliasList] PRIMARY KEY CLUSTERED ([AliasListId] ASC) WITH (FILLFACTOR = 70)
);


GO
CREATE NONCLUSTERED INDEX [APNO_Includes]
    ON [dbo].[Integration_Verification_AliasList]([APNO] ASC)
    INCLUDE([AliasListId], [VerificationCode], [VerificationName], [SSN], [SourceFound]) WITH (FILLFACTOR = 100);

