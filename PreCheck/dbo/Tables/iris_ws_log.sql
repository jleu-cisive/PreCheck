CREATE TABLE [dbo].[iris_ws_log] (
    [entity_name]   VARCHAR (35) NOT NULL,
    [entity_id]     BIGINT       NOT NULL,
    [data_id]       BIGINT       NOT NULL,
    [created_on]    DATETIME     NOT NULL,
    [log_item_type] VARCHAR (35) NOT NULL,
    CONSTRAINT [ck_iris_ws_log_entity_name] CHECK ([entity_name]='criminal_case' OR [entity_name]='screening' OR [entity_name]='order' OR [entity_name]='General'),
    CONSTRAINT [fk_iris_ws_log_data] FOREIGN KEY ([data_id]) REFERENCES [dbo].[iris_ws_log_data] ([id])
) ON [PRIMARY];


GO
CREATE NONCLUSTERED INDEX [entity_id_Includes]
    ON [dbo].[iris_ws_log]([entity_id] ASC)
    INCLUDE([entity_name], [data_id], [created_on], [log_item_type]) WITH (FILLFACTOR = 100)
    ON [PRIMARY];

