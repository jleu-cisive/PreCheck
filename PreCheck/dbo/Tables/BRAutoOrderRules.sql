CREATE TABLE [dbo].[BRAutoOrderRules] (
    [RuleID]      INT            IDENTITY (1, 1) NOT NULL,
    [KeyName]     NVARCHAR (50)  NOT NULL,
    [Operator]    NVARCHAR (10)  NULL,
    [Value]       NVARCHAR (50)  NULL,
    [Quantifier]  NVARCHAR (10)  NULL,
    [Description] NVARCHAR (100) NULL,
    [RuleTypeID]  INT            NOT NULL,
    CONSTRAINT [PK_BRAutoOrderRules] PRIMARY KEY CLUSTERED ([RuleID] ASC) WITH (FILLFACTOR = 50),
    CONSTRAINT [FK_BRAutoOrderRules_BRRuleTypes] FOREIGN KEY ([RuleTypeID]) REFERENCES [dbo].[BRRuleTypes] ([TypeID])
);

