CREATE TABLE [dbo].[refDeliveryMethod] (
    [DeliveryMethodID] INT           IDENTITY (1, 1) NOT NULL,
    [DeliveryMethod]   NVARCHAR (50) NULL,
    CONSTRAINT [PK_refDeliveryMethod] PRIMARY KEY CLUSTERED ([DeliveryMethodID] ASC) WITH (FILLFACTOR = 50)
);

