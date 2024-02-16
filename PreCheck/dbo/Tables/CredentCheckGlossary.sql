CREATE TABLE [dbo].[CredentCheckGlossary] (
    [CredentCheckGlossaryID] INT           IDENTITY (1, 1) NOT NULL,
    [Item]                   VARCHAR (100) NULL,
    [Description]            VARCHAR (800) NULL,
    [Grouping]               VARCHAR (100) NULL,
    CONSTRAINT [PK_CredentCheckGlossary] PRIMARY KEY CLUSTERED ([CredentCheckGlossaryID] ASC) WITH (FILLFACTOR = 50)
);

