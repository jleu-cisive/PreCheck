CREATE TABLE [dbo].[Integration_VendorOrder] (
    [Integration_VendorOrderId] INT            IDENTITY (1, 1) NOT NULL,
    [VendorName]                VARCHAR (1000) NULL,
    [VendorOperation]           VARCHAR (300)  NULL,
    [Request]                   XML            NULL,
    [Response]                  XML            NULL,
    [CreatedDate]               DATETIME       NULL,
    CONSTRAINT [PK_Integration_VendorOrder] PRIMARY KEY CLUSTERED ([Integration_VendorOrderId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_Integration_VendorOrder_CreatedDate]
    ON [dbo].[Integration_VendorOrder]([CreatedDate] ASC)
    INCLUDE([VendorName]);

