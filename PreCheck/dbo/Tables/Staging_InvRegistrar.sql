CREATE TABLE [dbo].[Staging_InvRegistrar] (
    [InvRegistrarID] INT           IDENTITY (1, 1) NOT NULL,
    [RunNumber]      INT           NOT NULL,
    [InvoiceNumber]  INT           NOT NULL,
    [CLNO]           INT           NOT NULL,
    [ClientName]     VARCHAR (255) NULL,
    [CutOffDate]     DATETIME      NOT NULL,
    [BillingCycle]   VARCHAR (8)   NOT NULL,
    [Sale]           MONEY         NOT NULL,
    [Tax]            MONEY         NOT NULL,
    [Locality]       VARCHAR (8)   NOT NULL,
    [Total]          MONEY         NOT NULL,
    [CreatedDate]    DATETIME      NULL
);

