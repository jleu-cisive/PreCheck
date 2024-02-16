CREATE TABLE [dbo].[HCABadBilling2] (
    [Note]                          NVARCHAR (255) NULL,
    [Conclusion]                    NVARCHAR (255) NULL,
    [ID]                            FLOAT (53)     NULL,
    [InvDetID]                      FLOAT (53)     NULL,
    [APNO]                          FLOAT (53)     NULL,
    [Type]                          FLOAT (53)     NULL,
    [Billed]                        FLOAT (53)     NULL,
    [InvoiceNumber]                 FLOAT (53)     NULL,
    [InvoiceMonth]                  FLOAT (53)     NULL,
    [InvoiceYear]                   FLOAT (53)     NULL,
    [CreateDate]                    DATETIME       NULL,
    [Description]                   NVARCHAR (255) NULL,
    [Amount]                        FLOAT (53)     NULL,
    [PrecheckPrice]                 FLOAT (53)     NULL,
    [ScaleFactor]                   FLOAT (53)     NULL,
    [LeadCountInPackage]            FLOAT (53)     NULL,
    [AdjustedPriceperPackage]       FLOAT (53)     NULL,
    [Passthru]                      NVARCHAR (255) NULL,
    [Frequency]                     FLOAT (53)     NULL,
    [componentprice]                NVARCHAR (255) NULL,
    [leadtype]                      NVARCHAR (255) NULL,
    [NumCase]                       FLOAT (53)     NULL,
    [Leadtypeid]                    FLOAT (53)     NULL,
    [LeadtypeDescription]           NVARCHAR (255) NULL,
    [NumLead]                       FLOAT (53)     NULL,
    [APNO - No Difference]          FLOAT (53)     NULL,
    [APNO - Variance/Remove All]    NVARCHAR (255) NULL,
    [APNO - Variance/Review Manual] NVARCHAR (255) NULL,
    [Count Hits]                    FLOAT (53)     NULL
);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20220205-155130]
    ON [dbo].[HCABadBilling2]([InvDetID] ASC);

