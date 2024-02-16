CREATE TABLE [dbo].[StateBoardSource] (
    [StateBoardSourceID]                    INT           IDENTITY (1, 1) NOT NULL,
    [SourceName]                            VARCHAR (200) NULL,
    [SourceState]                           CHAR (2)      NULL,
    [LicenseTypes]                          VARCHAR (200) NULL,
    [ContactPhone]                          CHAR (200)    NULL,
    [Frequency]                             VARCHAR (200) NULL,
    [LastUpdated]                           DATETIME      NULL,
    [NextRunDate]                           DATETIME      NULL,
    [VerificationURL]                       VARCHAR (200) NULL,
    [VerificationPhone]                     VARCHAR (200) NULL,
    [refStateBoardVerificationPreferenceID] INT           NULL,
    CONSTRAINT [PK_StateBoardSource] PRIMARY KEY CLUSTERED ([StateBoardSourceID] ASC) WITH (FILLFACTOR = 50)
);

