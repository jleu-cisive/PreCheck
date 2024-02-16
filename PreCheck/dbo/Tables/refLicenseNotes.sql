CREATE TABLE [dbo].[refLicenseNotes] (
    [LicenseNotesID] INT           IDENTITY (1, 1) NOT NULL,
    [LicenseNotes]   NVARCHAR (50) NULL,
    CONSTRAINT [PK_refLicenseNotes] PRIMARY KEY CLUSTERED ([LicenseNotesID] ASC) WITH (FILLFACTOR = 50)
);

