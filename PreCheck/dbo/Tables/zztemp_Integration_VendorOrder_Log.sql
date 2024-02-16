CREATE TABLE [dbo].[zztemp_Integration_VendorOrder_Log] (
    [Integration_VendorOrder_LogId] INT           IDENTITY (1, 1) NOT NULL,
    [Integration_VendorOrderId]     INT           NOT NULL,
    [IsProcessed]                   BIT           NULL,
    [StatusReceived]                VARCHAR (200) NULL,
    [OrderId]                       VARCHAR (50)  NULL,
    [CreatedDate]                   DATETIME      NULL,
    [ProcessedDate]                 DATETIME      NULL,
    [ErrorCount]                    INT           NULL
);

