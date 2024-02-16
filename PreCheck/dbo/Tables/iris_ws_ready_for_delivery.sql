CREATE TABLE [dbo].[iris_ws_ready_for_delivery] (
    [id]                  INT          IDENTITY (1, 1) NOT NULL,
    [screening_id]        INT          NOT NULL,
    [screening_qualifier] VARCHAR (50) NULL,
    [screening_type]      VARCHAR (50) NULL,
    [delivered]           BIT          NULL,
    CONSTRAINT [PK_iris_ws_ready_for_delivery] PRIMARY KEY CLUSTERED ([screening_id] ASC) WITH (FILLFACTOR = 50)
);

