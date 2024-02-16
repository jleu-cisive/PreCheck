CREATE TABLE [dbo].[StateBoardLicenseTypes] (
    [StateBoardLicenseTypeID] INT          IDENTITY (1, 1) NOT NULL,
    [StateBoardSourceID]      INT          NULL,
    [LicenseType]             VARCHAR (50) NULL,
    CONSTRAINT [PK_StateBoardLicenseTypes] PRIMARY KEY CLUSTERED ([StateBoardLicenseTypeID] ASC) WITH (FILLFACTOR = 50)
);

