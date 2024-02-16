CREATE TABLE [dbo].[rfl_personal] (
    [id]       INT          IDENTITY (1, 1) NOT NULL,
    [personal] VARCHAR (50) NULL,
    [category] VARCHAR (50) NULL,
    CONSTRAINT [PK_rfl_personal] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 50)
);

