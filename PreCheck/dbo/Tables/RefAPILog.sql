CREATE TABLE [dbo].[RefAPILog] (
    [Integration_vendorOrderId] INT            NOT NULL,
    [ReferenceId]               VARCHAR (20)   NULL,
    [Response]                  NVARCHAR (MAX) NULL,
    CONSTRAINT [PKID] PRIMARY KEY CLUSTERED ([Integration_vendorOrderId] ASC)
);

