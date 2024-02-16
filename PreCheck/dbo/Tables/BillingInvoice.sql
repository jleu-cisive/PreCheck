CREATE TABLE [dbo].[BillingInvoice] (
    [CLNO]          SMALLINT     NOT NULL,
    [InvoiceNumber] INT          NOT NULL,
    [InvDate]       DATETIME     NOT NULL,
    [BillingCycle]  NVARCHAR (2) NOT NULL,
    [pdf]           IMAGE        NULL,
    [ID]            INT          IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_BillingInvoice] PRIMARY KEY CLUSTERED ([CLNO] ASC, [InvoiceNumber] ASC)
);

