CREATE TABLE [dbo].[ClientConfig_Billing] (
    [ClientConfig_BillingID] INT IDENTITY (1, 1) NOT NULL,
    [CLNO]                   INT NOT NULL,
    [ComboEmplPersRefCount]  BIT NULL,
    [ZeroAdditionalItems]    BIT NULL,
    [LockPackagePricing]     BIT NULL,
    [NoPackageNoBill]        BIT NULL,
    CONSTRAINT [PK_ClientConfig_Billing] PRIMARY KEY CLUSTERED ([ClientConfig_BillingID] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [clno_unique]
    ON [dbo].[ClientConfig_Billing]([CLNO] ASC) WITH (FILLFACTOR = 50)
    ON [FG_INDEX];

