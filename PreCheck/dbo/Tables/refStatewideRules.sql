CREATE TABLE [dbo].[refStatewideRules] (
    [StatewideRulesID] INT           IDENTITY (1, 1) NOT NULL,
    [Description]      NVARCHAR (50) NULL,
    CONSTRAINT [PK_refStatewideRules] PRIMARY KEY CLUSTERED ([StatewideRulesID] ASC) WITH (FILLFACTOR = 50)
);

