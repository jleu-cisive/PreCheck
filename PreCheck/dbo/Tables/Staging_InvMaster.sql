CREATE TABLE [dbo].[Staging_InvMaster] (
    [ID]            INT        IDENTITY (1, 1) NOT NULL,
    [InvoiceNumber] INT        NULL,
    [CLNO]          SMALLINT   NOT NULL,
    [Printed]       BIT        NOT NULL,
    [InvDate]       DATETIME   NOT NULL,
    [Sale]          SMALLMONEY NOT NULL,
    [Tax]           SMALLMONEY NOT NULL
);

