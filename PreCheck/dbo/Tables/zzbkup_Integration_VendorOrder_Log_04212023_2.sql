CREATE TABLE [dbo].[zzbkup_Integration_VendorOrder_Log_04212023_2] (
    [Integration_VendorOrder_LogId] INT           NOT NULL,
    [Integration_VendorOrderId]     INT           NOT NULL,
    [IsProcessed]                   BIT           NULL,
    [OrderId]                       VARCHAR (50)  NULL,
    [ProcessedDate]                 DATETIME      NULL,
    [StatusReceived]                VARCHAR (200) NULL,
    [CreatedDate]                   DATETIME      NULL,
    [ErrorCount]                    INT           NULL,
    [VerificationType]              VARCHAR (50)  NULL,
    [DuplicateCount]                BIGINT        NULL
);

