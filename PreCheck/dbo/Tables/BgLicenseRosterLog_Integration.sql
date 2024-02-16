CREATE TABLE [dbo].[BgLicenseRosterLog_Integration] (
    [LicenseRosterLogID] INT            IDENTITY (1, 1) NOT NULL,
    [LicenseID]          INT            NOT NULL,
    [ActionCode]         VARCHAR (1)    NULL,
    [LogDate]            DATETIME       CONSTRAINT [DF_BgLicenseRoster_Log_LogDate] DEFAULT (getdate()) NOT NULL,
    [IntegrationMessage] VARCHAR (1000) NULL,
    CONSTRAINT [PK_LicenseRoster_Log] PRIMARY KEY CLUSTERED ([LicenseRosterLogID] ASC)
);

