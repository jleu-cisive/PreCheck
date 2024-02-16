CREATE TABLE [dbo].[ApplicationConfigurations] (
    [ConfigurationId]   INT           IDENTITY (1, 1) NOT NULL,
    [ApplicationName]   VARCHAR (500) NULL,
    [ConfigurationType] VARCHAR (500) NULL,
    [DataType]          VARCHAR (500) NULL,
    [ConfigurationData] XML           NOT NULL,
    [CreatedDate]       DATETIME      NOT NULL,
    [ModifiedDate]      DATETIME      NULL,
    [CreatedBy]         VARCHAR (500) NOT NULL,
    [ModifiedBy]        VARCHAR (500) NULL,
    CONSTRAINT [PK_ApplicationConfigurations] PRIMARY KEY CLUSTERED ([ConfigurationId] ASC) WITH (FILLFACTOR = 50)
);

