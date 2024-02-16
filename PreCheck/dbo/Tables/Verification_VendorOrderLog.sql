CREATE TABLE [dbo].[Verification_VendorOrderLog] (
    [Verification_VendorOrderLogID] INT           IDENTITY (1, 1) NOT NULL,
    [Integration_VendorOrderID]     INT           NOT NULL,
    [OperationType]                 VARCHAR (50)  NOT NULL,
    [VendorID]                      INT           NOT NULL,
    [OrderID]                       VARCHAR (50)  NOT NULL,
    [IsProcessed]                   BIT           NOT NULL,
    [ProcessedDate]                 DATETIME      NOT NULL,
    [CurrentOrderType]              VARCHAR (50)  NULL,
    [CurrentOrderStatus]            VARCHAR (50)  NULL,
    [SentCount]                     INT           NULL,
    [CurrentUpdateDate]             DATETIME      NULL,
    [Error]                         VARCHAR (MAX) NULL,
    [Exception]                     VARCHAR (MAX) NULL,
    [IsUsed]                        BIT           NOT NULL,
    [CreatedBy]                     VARCHAR (50)  NULL,
    [CreatedDate]                   DATETIME      NULL,
    CONSTRAINT [PK_Verification_VendorOrderLog] PRIMARY KEY CLUSTERED ([Verification_VendorOrderLogID] ASC) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];


GO
CREATE NONCLUSTERED INDEX [IX_Verification_VendorOrderLog_VendorID_OrderID]
    ON [dbo].[Verification_VendorOrderLog]([VendorID] ASC, [OrderID] ASC)
    ON [FG_INDEX];

