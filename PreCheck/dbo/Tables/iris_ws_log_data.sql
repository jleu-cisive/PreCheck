CREATE TABLE [dbo].[iris_ws_log_data] (
    [id]       BIGINT      IDENTITY (1, 1) NOT NULL,
    [hash_key] BINARY (20) NOT NULL,
    [data]     TEXT        NOT NULL,
    CONSTRAINT [pk_iris_ws_log_data] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 90, DATA_COMPRESSION = PAGE),
    CONSTRAINT [ak_iris_ws_log_data] UNIQUE NONCLUSTERED ([hash_key] ASC) WITH (FILLFACTOR = 50) ON [FG_INDEX]
) TEXTIMAGE_ON [PRIMARY];

