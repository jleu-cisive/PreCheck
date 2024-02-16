CREATE TABLE [dbo].[AdverseEmailTemplate] (
    [AdverseEmailTemplateID] INT           IDENTITY (1, 1) NOT NULL,
    [refAdverseStatusID]     INT           NULL,
    [From]                   VARCHAR (100) NULL,
    [Subject1]               VARCHAR (100) NULL,
    [Subject2]               VARCHAR (100) NULL,
    [Body1]                  VARCHAR (500) NULL,
    [Body2]                  VARCHAR (500) NULL,
    [Purpose]                VARCHAR (200) NULL,
    [TableName]              VARCHAR (100) NULL,
    [Text]                   VARCHAR (100) NULL,
    CONSTRAINT [PK_AdverseEmailTemplate] PRIMARY KEY CLUSTERED ([AdverseEmailTemplateID] ASC) WITH (FILLFACTOR = 50)
);

