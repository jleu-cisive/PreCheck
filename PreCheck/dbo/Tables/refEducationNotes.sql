CREATE TABLE [dbo].[refEducationNotes] (
    [EducationNotesID] INT           IDENTITY (1, 1) NOT NULL,
    [EducationNotes]   NVARCHAR (50) NULL,
    CONSTRAINT [PK_refEducationNotes] PRIMARY KEY CLUSTERED ([EducationNotesID] ASC) WITH (FILLFACTOR = 50)
);

