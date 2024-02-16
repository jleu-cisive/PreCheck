CREATE TABLE [dbo].[refStateCrimNotes] (
    [StateCrimNotesID] INT           IDENTITY (1, 1) NOT NULL,
    [StateCrimNotes]   NVARCHAR (50) NULL,
    CONSTRAINT [PK_refStateCrimNotes] PRIMARY KEY CLUSTERED ([StateCrimNotesID] ASC) WITH (FILLFACTOR = 50)
);

