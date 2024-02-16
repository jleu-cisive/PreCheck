CREATE TABLE [dbo].[refNoteType] (
    [NoteTypeID] INT           IDENTITY (1, 1) NOT NULL,
    [NoteType]   NVARCHAR (50) NULL,
    CONSTRAINT [PK_refNoteType] PRIMARY KEY CLUSTERED ([NoteTypeID] ASC) WITH (FILLFACTOR = 50)
);

