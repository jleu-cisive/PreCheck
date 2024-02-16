CREATE TABLE [dbo].[Rel_Cond_Stat] (
    [id]              INT          IDENTITY (1, 1) NOT NULL,
    [Rel_cond]        CHAR (2)     NULL,
    [Rel_Description] VARCHAR (50) NULL,
    CONSTRAINT [PK_Rel_Cond_Stat] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 50)
);

