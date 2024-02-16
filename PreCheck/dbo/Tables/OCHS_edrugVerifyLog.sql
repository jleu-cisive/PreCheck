CREATE TABLE [dbo].[OCHS_edrugVerifyLog] (
    [OCHS_edrugVerifyLogID] INT           IDENTITY (1, 1) NOT NULL,
    [APNO]                  INT           NULL,
    [OCHS_ID]               INT           NULL,
    [SSN]                   VARCHAR (11)  NULL,
    [DOB]                   DATE          NULL,
    [Last]                  VARCHAR (50)  NULL,
    [Email]                 VARCHAR (100) NULL,
    [LogDate]               DATETIME      CONSTRAINT [DF_OCHS_edrugVerifyLog_LogDate] DEFAULT (getdate()) NULL,
    [IsAuthenticated]       BIT           CONSTRAINT [DF_OCHS_edrugVerifyLog_IsAuthenticated] DEFAULT ((0)) NOT NULL,
    [SAML_PunchThrough]     BIT           CONSTRAINT [DF_OCHS_edrugVerifyLog_SAML_PunchThrough] DEFAULT ((0)) NOT NULL,
    [IsValidLink]           BIT           CONSTRAINT [DF_OCHS_edrugVerifyLog_IsValidLink] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_OCHS_edrugVerifyLog] PRIMARY KEY CLUSTERED ([OCHS_edrugVerifyLogID] ASC) WITH (FILLFACTOR = 50)
);

