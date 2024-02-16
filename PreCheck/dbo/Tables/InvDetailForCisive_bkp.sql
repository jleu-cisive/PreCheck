CREATE TABLE [dbo].[InvDetailForCisive_bkp] (
    [ID]                      INT           IDENTITY (1, 1) NOT NULL,
    [InvDetID]                INT           NOT NULL,
    [APNO]                    INT           NOT NULL,
    [Type]                    SMALLINT      NOT NULL,
    [Subkey]                  INT           NULL,
    [SubKeyChar]              VARCHAR (50)  NULL,
    [Billed]                  BIT           NOT NULL,
    [InvoiceNumber]           INT           NULL,
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
    CONSTRAINT [PK_ID] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 50),
    CONSTRAINT [FK_InvDetailForCisive_Appl] FOREIGN KEY ([APNO]) REFERENCES [dbo].[Appl] ([APNO]),
    CONSTRAINT [FK_InvDetailForCisive_InvDetID] FOREIGN KEY ([InvDetID]) REFERENCES [dbo].[InvDetail] ([InvDetID])
);

