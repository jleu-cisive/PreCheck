CREATE TABLE [dbo].[refBillingCycle] (
    [BillingCycleID] INT           IDENTITY (1, 1) NOT NULL,
    [BillingCycle]   NVARCHAR (50) NULL,
    CONSTRAINT [PK_refBillingCycle] PRIMARY KEY CLUSTERED ([BillingCycleID] ASC) WITH (FILLFACTOR = 50)
);

