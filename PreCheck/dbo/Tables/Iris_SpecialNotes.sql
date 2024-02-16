CREATE TABLE [dbo].[Iris_SpecialNotes] (
    [id]            INT  IDENTITY (1, 1) NOT NULL,
    [Special_notes] TEXT NULL,
    CONSTRAINT [PK_Iris_SpecialNotes] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 90)
) TEXTIMAGE_ON [PRIMARY];

