CREATE TABLE [dbo].[refTaxStatus] (
    [TaxStatusID] INT           IDENTITY (1, 1) NOT NULL,
    [TaxStatus]   NVARCHAR (50) NULL,
    CONSTRAINT [PK_refTaxStatus] PRIMARY KEY CLUSTERED ([TaxStatusID] ASC) WITH (FILLFACTOR = 50)
);

