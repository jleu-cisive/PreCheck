CREATE TABLE [dbo].[rfl_unfavorable] (
    [id]          INT           IDENTITY (1, 1) NOT NULL,
    [Unfavorable] VARCHAR (50)  NULL,
    [Category]    VARCHAR (100) NULL,
    CONSTRAINT [PK_rfl_unfavorable] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 50)
);

