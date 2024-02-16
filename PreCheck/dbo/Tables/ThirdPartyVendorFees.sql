CREATE TABLE [dbo].[ThirdPartyVendorFees] (
    [feeId]       INT            IDENTITY (1, 1) NOT NULL,
    [companyName] NVARCHAR (500) NOT NULL,
    [fee]         SMALLMONEY     NULL,
    [surCharge]   SMALLMONEY     NULL,
    PRIMARY KEY CLUSTERED ([feeId] ASC) WITH (FILLFACTOR = 70)
);

