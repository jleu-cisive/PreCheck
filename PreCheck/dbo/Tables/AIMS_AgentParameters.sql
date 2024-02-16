CREATE TABLE [dbo].[AIMS_AgentParameters] (
    [AgentParameterId]               INT           IDENTITY (1, 1) NOT NULL,
    [AgentParamName]                 VARCHAR (300) NULL,
    [AgentParamValue]                VARCHAR (300) NULL,
    [DataXtract_RequestMappingXMLId] INT           NOT NULL,
    CONSTRAINT [PK_AIMS_AgentParameters] PRIMARY KEY CLUSTERED ([AgentParameterId] ASC) WITH (FILLFACTOR = 70) ON [PRIMARY]
) ON [PRIMARY];

