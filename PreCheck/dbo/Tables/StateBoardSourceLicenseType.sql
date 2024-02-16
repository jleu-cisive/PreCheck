CREATE TABLE [dbo].[StateBoardSourceLicenseType] (
    [ID]            INT          IDENTITY (1, 1) NOT NULL,
    [SourceID]      INT          NULL,
    [LicenseTypeID] INT          NULL,
    [LicenseType]   VARCHAR (50) NULL,
    CONSTRAINT [PK_StateBoardSourceLicenseType] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 50)
);

