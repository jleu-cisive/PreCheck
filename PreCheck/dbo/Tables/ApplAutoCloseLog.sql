CREATE TABLE [dbo].[ApplAutoCloseLog] (
    [Apno]     INT      NOT NULL,
    [ClosedOn] DATETIME CONSTRAINT [DF_ApplAutoCloseLog_ClosedOn] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [FK_ApplAutoCloseLog_Appl] FOREIGN KEY ([Apno]) REFERENCES [dbo].[Appl] ([APNO])
);


GO
CREATE NONCLUSTERED INDEX [IX_ApplAutoCloseLog]
    ON [dbo].[ApplAutoCloseLog]([ClosedOn] ASC)
    ON [FG_INDEX];

