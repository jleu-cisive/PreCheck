CREATE TABLE [dbo].[ClientNotesBackUp] (
    [NoteID]   INT           IDENTITY (1, 1) NOT NULL,
    [CLNO]     SMALLINT      NOT NULL,
    [NoteType] VARCHAR (50)  NULL,
    [NoteBy]   VARCHAR (50)  NULL,
    [NoteDate] SMALLDATETIME NULL,
    [NoteText] TEXT          NULL
);

