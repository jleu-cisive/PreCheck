CREATE TABLE [dbo].[BgLicenseRoster_Integration] (
    [LicenseRoster_IntegrationID] INT          IDENTITY (1, 1) NOT NULL,
    [LicenseID]                   INT          NOT NULL,
    [IsActive]                    BIT          CONSTRAINT [DF_BgLicenseRoster_Integration_IsActive] DEFAULT ((1)) NOT NULL,
    [ActionCode]                  VARCHAR (1)  NULL,
    [CreatedDate]                 DATETIME     CONSTRAINT [DF_BgLicenseRoster_Integration_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastUpdated]                 DATETIME     CONSTRAINT [DF_BgLicenseRoster_Integration_LastUpdated] DEFAULT (getdate()) NOT NULL,
    [AttemptCounter]              INT          CONSTRAINT [DF_BgLicenseRoster_Integration_AttemptCounter] DEFAULT ((0)) NOT NULL,
    [LicenseType]                 VARCHAR (50) NULL,
    [LicenseState]                VARCHAR (2)  NULL,
    CONSTRAINT [PK_BgLicenseRoster_Integration] PRIMARY KEY CLUSTERED ([LicenseRoster_IntegrationID] ASC)
);

