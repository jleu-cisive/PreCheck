CREATE TABLE [dbo].[refVerificationSources] (
    [refVerificationSource] VARCHAR (10)  NOT NULL,
    [Description]           VARCHAR (100) NOT NULL,
    [Section]               VARCHAR (10)  NOT NULL,
    [IsActive]              BIT           CONSTRAINT [DF_refVerificationSources_IsActive] DEFAULT ((0)) NOT NULL,
    [minlength]             INT           CONSTRAINT [DF_refVerificationSources_minlength] DEFAULT ((0)) NOT NULL,
    [maxlength]             INT           CONSTRAINT [DF_refVerificationSources_maxlength] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_refVerificationSources] PRIMARY KEY CLUSTERED ([refVerificationSource] ASC) WITH (FILLFACTOR = 50)
);

