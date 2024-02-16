CREATE TABLE [dbo].[InvDescForCisive] (
    [ID]                      INT           IDENTITY (1, 1) NOT NULL,
    [Type]                    SMALLINT      NOT NULL,
    [Description]             VARCHAR (100) NULL,
    [length]                  INT           NULL,
    [Amount]                  SMALLMONEY    NULL,
    [LeadCountInPackage]      INT           NULL,
    [AdjustedPriceperPackage] SMALLMONEY    NULL,
    [Passthru]                SMALLMONEY    NULL,
    [leadtype]                VARCHAR (50)  NULL,
    [NumCase]                 SMALLMONEY    NULL,
    [Leadtypeid]              INT           NULL,
    [LeadtypeDescription]     VARCHAR (40)  NULL,
    CONSTRAINT [PKdesc2020_ID] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 50)
);

