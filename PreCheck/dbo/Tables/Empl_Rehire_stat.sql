CREATE TABLE [dbo].[Empl_Rehire_stat] (
    [id]          INT          IDENTITY (1, 1) NOT NULL,
    [Rehire]      VARCHAR (50) NULL,
    [Description] VARCHAR (50) NULL,
    CONSTRAINT [PK_Empl_Rehire_stat] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 50)
);

