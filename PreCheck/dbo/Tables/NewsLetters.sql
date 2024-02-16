CREATE TABLE [dbo].[NewsLetters] (
    [NewsLettersID] INT           IDENTITY (1, 1) NOT NULL,
    [NewsDate]      VARCHAR (20)  NULL,
    [Subject]       VARCHAR (200) NULL,
    [FileName]      VARCHAR (200) NULL,
    [URL]           VARCHAR (200) NULL,
    CONSTRAINT [PK_NewsLetters] PRIMARY KEY CLUSTERED ([NewsLettersID] ASC) WITH (FILLFACTOR = 50)
);

