CREATE TABLE [dbo].[zzz_bkup_Integration_VendorOrder_Log_11012022] (
    [Integration_VendorOrder_LogId] INT           IDENTITY (1, 1) NOT NULL,
    [Integration_VendorOrderId]     INT           NOT NULL,
    [IsProcessed]                   BIT           NULL,
    [StatusReceived]                VARCHAR (200) NULL,
    [OrderId]                       VARCHAR (50)  NULL,
    [CreatedDate]                   DATETIME      NULL,
    [ProcessedDate]                 DATETIME      NULL,
    [ErrorCount]                    INT           NULL
);

