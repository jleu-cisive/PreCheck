CREATE TABLE [dbo].[StateBoardLicenseNumber] (
    [StateBoardLicenseNumberID]   INT          IDENTITY (1, 1) NOT NULL,
    [StateBoardDisciplinaryRunID] INT          NULL,
    [LicenseNumber]               VARCHAR (50) NULL,
    [UserID]                      VARCHAR (10) NULL,
    CONSTRAINT [PK_StateBoardLicenseNumber] PRIMARY KEY CLUSTERED ([StateBoardLicenseNumberID] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE NONCLUSTERED INDEX [IX_StateBoardLicenseNumber]
    ON [dbo].[StateBoardLicenseNumber]([StateBoardDisciplinaryRunID] ASC) WITH (FILLFACTOR = 50)
    ON [FG_INDEX];

