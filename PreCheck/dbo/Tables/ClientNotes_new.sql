CREATE TABLE [dbo].[ClientNotes_new] (
    [NoteID]   INT           IDENTITY (1, 1) NOT NULL,
    [CLNO]     SMALLINT      NOT NULL,
    [NoteType] VARCHAR (50)  NULL,
    [NoteBy]   VARCHAR (50)  NULL,
    [NoteDate] SMALLDATETIME NULL,
    [NoteText] TEXT          NULL,
    CONSTRAINT [PK_ClientNotes_new] PRIMARY KEY CLUSTERED ([NoteID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_ClientNotes_Client_new] FOREIGN KEY ([CLNO]) REFERENCES [dbo].[Client] ([CLNO])
) TEXTIMAGE_ON [PRIMARY];


GO
CREATE NONCLUSTERED INDEX [IX_CLNO]
    ON [dbo].[ClientNotes_new]([CLNO] ASC) WITH (FILLFACTOR = 50)
    ON [FG_INDEX];

