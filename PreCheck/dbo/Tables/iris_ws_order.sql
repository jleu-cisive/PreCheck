CREATE TABLE [dbo].[iris_ws_order] (
    [id]             BIGINT           IDENTITY (1, 1) NOT NULL,
    [alt_id]         UNIQUEIDENTIFIER NOT NULL,
    [vendor_type_id] BIGINT           NOT NULL,
    [applicant_id]   INT              NOT NULL,
    [created_on]     DATETIME         NOT NULL,
    CONSTRAINT [pk_iris_ws_order] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 50),
    CONSTRAINT [fk_iris_ws_order_applicant] FOREIGN KEY ([applicant_id]) REFERENCES [dbo].[Appl] ([APNO]),
    CONSTRAINT [fk_iris_ws_order_vendor_type] FOREIGN KEY ([vendor_type_id]) REFERENCES [dbo].[iris_ws_vendor_type] ([id])
);


GO
CREATE NONCLUSTERED INDEX [ak_iris_ws_order]
    ON [dbo].[iris_ws_order]([alt_id] ASC, [id] ASC) WITH (FILLFACTOR = 50)
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [applicant_id_Includes]
    ON [dbo].[iris_ws_order]([applicant_id] ASC)
    INCLUDE([id]) WITH (FILLFACTOR = 100);

