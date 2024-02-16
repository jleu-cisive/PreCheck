CREATE TABLE [dbo].[StateBoardAplusBLicenseNumber] (
    [StateBoardAplusBLicenseNumberID] INT          IDENTITY (1, 1) NOT NULL,
    [A_LicenseNumber]                 VARCHAR (50) NULL,
    [A_UserID]                        VARCHAR (50) NULL,
    [B_LicenseNumber]                 VARCHAR (50) NULL,
    [B_UserID]                        VARCHAR (50) NULL,
    CONSTRAINT [PK_StateBoardAplusBLicenseNumber] PRIMARY KEY CLUSTERED ([StateBoardAplusBLicenseNumberID] ASC) WITH (FILLFACTOR = 50)
);

