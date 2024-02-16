CREATE TABLE [dbo].[refBRSourceAutoOrderRules] (
    [SourcePriorityID] INT NOT NULL,
    [RuleID]           INT NOT NULL,
    CONSTRAINT [PK_refBRSourceAutoOrderRules] PRIMARY KEY CLUSTERED ([SourcePriorityID] ASC, [RuleID] ASC) WITH (FILLFACTOR = 50),
    CONSTRAINT [FK_refSourceAutoOrderRules_BRAutoOrderRules] FOREIGN KEY ([RuleID]) REFERENCES [dbo].[BRAutoOrderRules] ([RuleID]),
    CONSTRAINT [FK_refSourceAutoOrderRules_refBRSourcePriority] FOREIGN KEY ([SourcePriorityID]) REFERENCES [dbo].[refBRSourcePriority] ([RefID])
);

