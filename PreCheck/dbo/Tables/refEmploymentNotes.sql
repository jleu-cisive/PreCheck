CREATE TABLE [dbo].[refEmploymentNotes] (
    [EmploymentNotesID] INT           IDENTITY (1, 1) NOT NULL,
    [EmploymentNotes]   NVARCHAR (50) NULL,
    CONSTRAINT [PK_refEmploymentNotes] PRIMARY KEY CLUSTERED ([EmploymentNotesID] ASC) WITH (FILLFACTOR = 50)
);

