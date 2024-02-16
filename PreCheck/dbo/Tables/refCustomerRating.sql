CREATE TABLE [dbo].[refCustomerRating] (
    [CustomerRatingID] INT           IDENTITY (1, 1) NOT NULL,
    [CustomerRating]   NVARCHAR (50) NULL,
    CONSTRAINT [PK_refCustomerRating] PRIMARY KEY CLUSTERED ([CustomerRatingID] ASC) WITH (FILLFACTOR = 50)
);

