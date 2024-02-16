CREATE TABLE [dbo].[BRRuleTypes] (
    [TypeID]      INT            IDENTITY (1, 1) NOT NULL,
    [RuleType]    NVARCHAR (25)  NOT NULL,
    [Description] NVARCHAR (100) NULL,
    CONSTRAINT [PK_BRRuleTypes] PRIMARY KEY CLUSTERED ([TypeID] ASC) WITH (FILLFACTOR = 50)
);

