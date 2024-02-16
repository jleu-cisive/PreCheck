CREATE TABLE [dbo].[Empl_Type_Stat] (
    [id]              INT          IDENTITY (1, 1) NOT NULL,
    [Emp_Type]        CHAR (2)     NULL,
    [Emp_Description] VARCHAR (50) NULL,
    CONSTRAINT [PK_Empl_Type_Stat] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE NONCLUSTERED INDEX [IX_Empl_Type_Stat]
    ON [dbo].[Empl_Type_Stat]([Emp_Type] ASC) WITH (FILLFACTOR = 50)
    ON [FG_INDEX];

