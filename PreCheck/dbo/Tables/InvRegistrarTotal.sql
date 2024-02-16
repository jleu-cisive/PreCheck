CREATE TABLE [dbo].[InvRegistrarTotal] (
    [InvRegistrarTotalID] INT         IDENTITY (1, 1) NOT NULL,
    [RunNumber]           INT         NOT NULL,
    [InvCount]            INT         NOT NULL,
    [TotalSale]           MONEY       NOT NULL,
    [TotalTax]            MONEY       NOT NULL,
    [CutOffDate]          DATETIME    NOT NULL,
    [BillingCycle]        VARCHAR (8) NOT NULL,
    [CreatedDate]         DATETIME    NULL,
    CONSTRAINT [PK_InvRegistrarTotal] PRIMARY KEY CLUSTERED ([InvRegistrarTotalID] ASC) WITH (FILLFACTOR = 50)
);

