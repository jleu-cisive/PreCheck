CREATE TABLE [dbo].[NotifyTemplate] (
    [NotifyTemplateId]   INT           IDENTITY (1, 1) NOT NULL,
    [NotifyTemplateName] VARCHAR (100) NOT NULL,
    [AssociatedStatusId] INT           NULL,
    [NotifySubject]      VARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([NotifyTemplateId] ASC)
);

