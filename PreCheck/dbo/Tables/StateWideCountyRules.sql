CREATE TABLE [dbo].[StateWideCountyRules] (
    [StateCountyID]    INT IDENTITY (1, 1) NOT NULL,
    [StatewideID]      INT NOT NULL,
    [CNTY_NO]          INT NOT NULL,
    [StatewideRulesID] INT NOT NULL,
    CONSTRAINT [PK_StateWideCountyRules] PRIMARY KEY CLUSTERED ([StateCountyID] ASC) WITH (FILLFACTOR = 50)
);

