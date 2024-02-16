CREATE TABLE [dbo].[rfl_business] (
    [ID]       INT          IDENTITY (1, 1) NOT NULL,
    [Business] VARCHAR (50) NULL,
    [Category] VARCHAR (50) NULL,
    CONSTRAINT [PK_rfl_business] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 50)
);

