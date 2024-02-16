CREATE TABLE [dbo].[refAffiliate] (
    [AffiliateID] INT           IDENTITY (1, 1) NOT NULL,
    [Affiliate]   NVARCHAR (50) NULL,
    CONSTRAINT [PK_refAffiliate] PRIMARY KEY CLUSTERED ([AffiliateID] ASC) WITH (FILLFACTOR = 50)
);

