CREATE TABLE [dbo].[refTaxLocale] (
    [TaxLocaleID]   INT          IDENTITY (1, 1) NOT NULL,
    [TaxLocale]     VARCHAR (50) NULL,
    [MAS90Schedule] VARCHAR (9)  NULL,
    [TaxRate]       SMALLMONEY   NULL,
    CONSTRAINT [PK_refTaxLocale] PRIMARY KEY CLUSTERED ([TaxLocaleID] ASC) WITH (FILLFACTOR = 50)
);

