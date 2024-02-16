CREATE TABLE [dbo].[Billing_PassThruClients] (
    [Id]   INT IDENTITY (1, 1) NOT NULL,
    [CLNO] INT NULL,
    CONSTRAINT [PK_Billing_PassThruClients] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 50)
);

