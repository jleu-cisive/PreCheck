CREATE TABLE [dbo].[MayInvoiceDetailsSJV] (
    [Order Date]               NVARCHAR (255) NULL,
    [Order Id]                 FLOAT (53)     NULL,
    [State]                    NVARCHAR (255) NULL,
    [Jurisdiction]             NVARCHAR (255) NULL,
    [Name]                     NVARCHAR (255) NULL,
    [Ref#]                     NVARCHAR (255) NULL,
    [Product]                  NVARCHAR (255) NULL,
    [Type]                     NVARCHAR (255) NULL,
    [Cost]                     MONEY          NULL,
    [Court Fee]                MONEY          NULL,
    [Data Fee]                 MONEY          NULL,
    [Total]                    MONEY          NULL,
    [Client Order Id]          NVARCHAR (255) NULL,
    [Client Subject Id]        NVARCHAR (255) NULL,
    [Client External Order Id] NVARCHAR (255) NULL
);

