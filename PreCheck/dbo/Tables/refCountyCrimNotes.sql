CREATE TABLE [dbo].[refCountyCrimNotes] (
    [CountyCrimNotesID] INT           IDENTITY (1, 1) NOT NULL,
    [CountyCrimNotes]   NVARCHAR (50) NULL,
    CONSTRAINT [PK_refCountyCrimNotes] PRIMARY KEY CLUSTERED ([CountyCrimNotesID] ASC) WITH (FILLFACTOR = 50)
);

