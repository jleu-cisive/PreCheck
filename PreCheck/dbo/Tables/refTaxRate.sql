CREATE TABLE [dbo].[refTaxRate] (
    [TaxRateID] INT        IDENTITY (1, 1) NOT NULL,
    [TaxRate]   SMALLMONEY NULL,
    CONSTRAINT [PK_refTaxRate] PRIMARY KEY CLUSTERED ([TaxRateID] ASC) WITH (FILLFACTOR = 50)
);

