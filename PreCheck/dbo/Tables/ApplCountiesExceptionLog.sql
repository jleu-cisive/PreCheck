CREATE TABLE [dbo].[ApplCountiesExceptionLog] (
    [Apno]     INT      NOT NULL,
    [SourceID] INT      NOT NULL,
    [RuleID]   INT      NOT NULL,
    [LogDate]  DATETIME CONSTRAINT [DF_ApplCountiesExceptionLog_LogDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [FK_ApplCountiesExceptionLog_Appl] FOREIGN KEY ([Apno]) REFERENCES [dbo].[Appl] ([APNO]),
    CONSTRAINT [FK_ApplCountiesExceptionLog_BRAutoOrderRules] FOREIGN KEY ([RuleID]) REFERENCES [dbo].[BRAutoOrderRules] ([RuleID]),
    CONSTRAINT [FK_ApplCountiesExceptionLog_BRSources] FOREIGN KEY ([SourceID]) REFERENCES [dbo].[BRSources] ([SourceID])
);


GO
ALTER TABLE [dbo].[ApplCountiesExceptionLog] NOCHECK CONSTRAINT [FK_ApplCountiesExceptionLog_BRAutoOrderRules];

