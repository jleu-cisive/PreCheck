CREATE TABLE [dbo].[Integration_VendorOrder_Log] (
    [Integration_VendorOrder_LogId] INT           IDENTITY (1, 1) NOT NULL,
    [Integration_VendorOrderId]     INT           NOT NULL,
    [IsProcessed]                   BIT           DEFAULT ((1)) NULL,
    [StatusReceived]                VARCHAR (200) NULL,
    [OrderId]                       VARCHAR (50)  NULL,
    [CreatedDate]                   DATETIME      DEFAULT (getdate()) NULL,
    [ProcessedDate]                 DATETIME      NULL,
    [ErrorCount]                    INT           NULL,
    CONSTRAINT [PK_Integration_VendorOrder_Log] PRIMARY KEY CLUSTERED ([Integration_VendorOrder_LogId] ASC) WITH (FILLFACTOR = 70)
);


GO
CREATE NONCLUSTERED INDEX [OrderId]
    ON [dbo].[Integration_VendorOrder_Log]([OrderId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [Integration_VendorOrder_Log_IsProcessed_StatusReceived_ProcessedDate_ErrorCount]
    ON [dbo].[Integration_VendorOrder_Log]([IsProcessed] ASC, [StatusReceived] ASC, [ProcessedDate] ASC, [ErrorCount] ASC);

