CREATE TABLE [dbo].[iris_ws_vendor_type] (
    [id]                  BIGINT       IDENTITY (1, 1) NOT NULL,
    [code]                VARCHAR (10) NOT NULL,
    [alt_delivery_method] VARCHAR (35) NOT NULL,
    [CreateAlias]         BIT          CONSTRAINT [DF_iris_ws_vendor_type_CreateAlias] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [pk_iris_ws_vendor_type] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 50),
    CONSTRAINT [ak_iris_ws_vendor_type] UNIQUE NONCLUSTERED ([code] ASC) WITH (FILLFACTOR = 50) ON [PRIMARY]
);

