CREATE TABLE [dbo].[ClientConfig_Integration_Template] (
    [TemplateId]             INT NOT NULL,
    [ClientATSId]            INT NOT NULL,
    [ConfigSettingsTemplate] XML NULL,
    PRIMARY KEY CLUSTERED ([TemplateId] ASC) WITH (FILLFACTOR = 70)
);

