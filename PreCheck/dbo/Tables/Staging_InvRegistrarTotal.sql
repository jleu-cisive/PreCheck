CREATE TABLE [dbo].[Staging_InvRegistrarTotal] (
    [InvRegistrarTotalID] INT         IDENTITY (1, 1) NOT NULL,
    [RunNumber]           INT         NOT NULL,
    [InvCount]            INT         NOT NULL,
    [TotalSale]           MONEY       NOT NULL,
    [TotalTax]            MONEY       NOT NULL,
    [CutOffDate]          DATETIME    NOT NULL,
    [BillingCycle]        VARCHAR (8) NOT NULL,
    [CreatedDate]         DATETIME    NULL
);

