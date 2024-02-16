CREATE TABLE [dbo].[VendorBilling] (
    [ItemId]         INT           NOT NULL,
    [APNO]           INT           NULL,
    [BillingType]    VARCHAR (40)  NULL,
    [VendorId]       INT           NULL,
    [BillingSubject] VARCHAR (100) NULL,
    [BillingAmount]  DECIMAL (18)  NULL,
    [CreatedBy]      VARCHAR (50)  NULL,
    [CreatedDate]    DATETIME      NULL,
    CONSTRAINT [PK_VendorBilling] PRIMARY KEY CLUSTERED ([ItemId] ASC) WITH (FILLFACTOR = 50)
);

