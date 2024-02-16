﻿CREATE TABLE [dbo].[InvDetailToNetsuite] (
    [ID]                      INT           IDENTITY (1, 1) NOT NULL,
    [InvDetID]                INT           NOT NULL,
    [APNO]                    INT           NOT NULL,
    [Type]                    SMALLINT      NOT NULL,
    [Subkey]                  INT           NULL,
    [SubKeyChar]              VARCHAR (50)  NULL,
    [Billed]                  BIT           NOT NULL,
    [InvoiceNumber]           INT           NULL,
    [InvoiceMonth]            INT           NULL,
    [InvoiceYear]             INT           NULL,
    [CreateDate]              DATETIME      NOT NULL,
    [Description]             VARCHAR (100) NULL,
    [Amount]                  SMALLMONEY    NULL,
    [PrecheckPrice]           SMALLMONEY    NULL,
    [ScaleFactor]             SMALLMONEY    NULL,
    [LeadCountInPackage]      INT           NULL,
    [AdjustedPriceperPackage] SMALLMONEY    NULL,
    [Passthru]                SMALLMONEY    NULL,
    [Frequency]               INT           NULL,
    [componentprice]          SMALLMONEY    NULL,
    [leadtype]                VARCHAR (50)  NULL,
    [NumCase]                 FLOAT (53)    NULL,
    [Leadtypeid]              INT           NULL,
    [LeadtypeDescription]     VARCHAR (40)  NULL,
    [NumLead]                 INT           NULL,
    CONSTRAINT [PKNetsuite_ID] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE NONCLUSTERED INDEX [InvoiceMonth_InvoiceYear]
    ON [dbo].[InvDetailToNetsuite]([InvoiceMonth] ASC, [InvoiceYear] ASC);

