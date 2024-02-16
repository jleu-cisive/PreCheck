CREATE TABLE [dbo].[CrimVendorResend] (
    [VendorID] INT         NOT NULL,
    [InUse]    VARCHAR (8) NULL,
    CONSTRAINT [PK_CrimVendorResend] PRIMARY KEY CLUSTERED ([VendorID] ASC) WITH (FILLFACTOR = 50)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary key and also foreign key to table, dbo.Iris_Researchers. WinService will read any records in this table and send all pending items to the vendor. Afterward, WinService will delete that vendor from this table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CrimVendorResend', @level2type = N'COLUMN', @level2name = N'VendorID';

