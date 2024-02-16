CREATE TABLE [dbo].[InvCreateInvoiceQueue] (
    [InvCreateInvoiceQueueID] INT         IDENTITY (1, 1) NOT NULL,
    [RunNumber]               INT         NOT NULL,
    [CLNO]                    INT         NOT NULL,
    [BillingCycle]            VARCHAR (8) NOT NULL,
    [CutOffDate]              DATETIME    NOT NULL,
    CONSTRAINT [PK_InvCreateInvoiceQueue] PRIMARY KEY CLUSTERED ([InvCreateInvoiceQueueID] ASC) WITH (FILLFACTOR = 50)
);

