CREATE TABLE [dbo].[NoteIt] (
    [NoteItID]     INT         IDENTITY (1, 1) NOT NULL,
    [DepartmentID] INT         NOT NULL,
    [Note]         TEXT        NOT NULL,
    [CreateDate]   DATETIME    CONSTRAINT [DF_NoteIt_CreateDate] DEFAULT (getdate()) NOT NULL,
    [UserID]       VARCHAR (8) NULL,
    CONSTRAINT [PK_Note] PRIMARY KEY CLUSTERED ([NoteItID] ASC)
) TEXTIMAGE_ON [PRIMARY];

