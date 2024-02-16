CREATE TABLE [dbo].[rfl_education] (
    [id]        INT          IDENTITY (1, 1) NOT NULL,
    [Education] VARCHAR (50) NULL,
    [Category]  VARCHAR (50) NULL,
    CONSTRAINT [PK_rfl_education] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 50)
);

