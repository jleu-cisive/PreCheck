CREATE TABLE [dbo].[refLicContactMethod] (
    [refLicContactMethodID] INT          IDENTITY (1, 1) NOT NULL,
    [Description]           VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_refLicContactMethod] PRIMARY KEY CLUSTERED ([refLicContactMethodID] ASC) WITH (FILLFACTOR = 50)
);

