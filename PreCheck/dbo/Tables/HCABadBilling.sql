CREATE TABLE [dbo].[HCABadBilling] (
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
    [componentprice]                FLOAT (53)     NULL,
    [leadtype]                      NVARCHAR (255) NULL,
    [NumCase]                       FLOAT (53)     NULL,
    [Leadtypeid]                    FLOAT (53)     NULL,
    [LeadtypeDescription]           NVARCHAR (255) NULL,
    [NumLead]                       FLOAT (53)     NULL,
    [APNO - No Difference]          NVARCHAR (255) NULL,
    [APNO - Variance/Remove All]    NVARCHAR (255) NULL,
    [APNO - Variance/Review Manual] FLOAT (53)     NULL,
    [Count Hits]                    FLOAT (53)     NULL
);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20220205-155027]
    ON [dbo].[HCABadBilling]([InvDetID] ASC);

