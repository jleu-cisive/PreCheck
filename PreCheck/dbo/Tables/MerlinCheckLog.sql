CREATE TABLE [dbo].[MerlinCheckLog] (
    [MerlinCheckID] INT      IDENTITY (1, 1) NOT NULL,
    [Apno]          INT      NULL,
    [Contents]      TEXT     NULL,
    [Length]        INT      NULL,
    [MerlinDate]    DATETIME CONSTRAINT [DF_MerlinCheckLog_MerlinDate] DEFAULT (getdate()) NULL,
    [Clno]          INT      NULL,
    [UserID]        INT      NULL,
    CONSTRAINT [PK_MerlinCheckLog] PRIMARY KEY CLUSTERED ([MerlinCheckID] ASC) WITH (FILLFACTOR = 90)
) TEXTIMAGE_ON [PRIMARY];

