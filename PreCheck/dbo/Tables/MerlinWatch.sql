CREATE TABLE [dbo].[MerlinWatch] (
    [MerlinWatchID] INT      IDENTITY (1, 1) NOT NULL,
    [Apno]          INT      NULL,
    [ProcessStart]  DATETIME NULL,
    [ProcessEnd]    DATETIME NULL,
    CONSTRAINT [PK_MerlinWatch] PRIMARY KEY CLUSTERED ([MerlinWatchID] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE NONCLUSTERED INDEX [APNO]
    ON [dbo].[MerlinWatch]([Apno] ASC) WITH (FILLFACTOR = 50)
    ON [FG_INDEX];

