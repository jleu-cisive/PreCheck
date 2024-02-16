CREATE TABLE [dbo].[iris_ws_criminal_case] (
    [id]           BIGINT       IDENTITY (1, 1) NOT NULL,
    [screening_id] BIGINT       NOT NULL,
    [case_number]  VARCHAR (35) NOT NULL,
    [created_on]   DATETIME     NOT NULL,
    CONSTRAINT [pk_iris_ws_criminal_case] PRIMARY KEY NONCLUSTERED ([id] ASC) WITH (FILLFACTOR = 50) ON [FG_DATA],
    CONSTRAINT [fk_iris_ws_criminal_case_screening] FOREIGN KEY ([screening_id]) REFERENCES [dbo].[iris_ws_screening] ([id]),
    CONSTRAINT [ak_iris_ws_criminal_case] UNIQUE CLUSTERED ([screening_id] ASC, [case_number] ASC) WITH (FILLFACTOR = 50) ON [PRIMARY]
) ON [PRIMARY];

