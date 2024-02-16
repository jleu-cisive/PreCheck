CREATE TABLE [dbo].[rfl_health] (
    [id]       INT          IDENTITY (1, 1) NOT NULL,
    [health]   VARCHAR (50) NULL,
    [category] VARCHAR (50) NULL,
    CONSTRAINT [PK_rfl_health] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 50)
);

