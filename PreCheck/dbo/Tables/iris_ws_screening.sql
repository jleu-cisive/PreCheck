CREATE TABLE [dbo].[iris_ws_screening] (
    [id]               BIGINT       IDENTITY (1, 1) NOT NULL,
    [vendor_search_id] INT          NOT NULL,
    [order_id]         BIGINT       NOT NULL,
    [crim_id]          INT          NOT NULL,
    [order_status]     VARCHAR (35) NOT NULL,
    [result_status]    VARCHAR (35) NOT NULL,
    [is_confirmed]     CHAR (1)     CONSTRAINT [df_iris_ws_screening_is_confirmed] DEFAULT ('F') NOT NULL,
    [created_on]       DATETIME     NOT NULL,
    [updated_on]       DATETIME     NOT NULL,
    CONSTRAINT [pk_iris_ws_screening] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 50),
    CONSTRAINT [ck_iris_ws_screening_is_confirmed] CHECK ([is_confirmed]='F' OR [is_confirmed]='T'),
    CONSTRAINT [fk_iris_ws_screening_order] FOREIGN KEY ([order_id]) REFERENCES [dbo].[iris_ws_order] ([id]),
    CONSTRAINT [FK_iris_ws_screening_researcher_charges] FOREIGN KEY ([vendor_search_id]) REFERENCES [dbo].[Iris_Researcher_Charges] ([id])
);


GO
CREATE NONCLUSTERED INDEX [ak_iris_ws_screening]
    ON [dbo].[iris_ws_screening]([order_id] ASC, [crim_id] ASC, [id] ASC) WITH (FILLFACTOR = 50)
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [IDX_iris_ws_screening_CrimID]
    ON [dbo].[iris_ws_screening]([crim_id] ASC)
    INCLUDE([updated_on]) WITH (FILLFACTOR = 70);

