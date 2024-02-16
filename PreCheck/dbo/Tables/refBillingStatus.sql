CREATE TABLE [dbo].[refBillingStatus] (
    [BillingStatusID]   INT           IDENTITY (1, 1) NOT NULL,
    [BillingStatus]     NVARCHAR (50) NULL,
    [BillingStatusCode] VARCHAR (1)   NULL,
    CONSTRAINT [PK_refBillingStatus] PRIMARY KEY CLUSTERED ([BillingStatusID] ASC) WITH (FILLFACTOR = 50)
);

