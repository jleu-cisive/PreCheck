CREATE TABLE [dbo].[zzbkup_Integration_VendorOrder_Log_04202023] (
    [Integration_VendorOrder_LogId] INT           NOT NULL,
    [Integration_VendorOrderId]     INT           NOT NULL,
    [IsProcessed]                   BIT           NULL,
    [StatusReceived]                VARCHAR (200) NULL,
    [OrderId]                       VARCHAR (50)  NULL,
    [CreatedDate]                   DATETIME      NULL,
    [ProcessedDate]                 DATETIME      NULL,
    [ErrorCount]                    INT           NULL,
    [DuplicateCount]                BIGINT        NULL
);

