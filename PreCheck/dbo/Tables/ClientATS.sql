CREATE TABLE [dbo].[ClientATS] (
    [ClientATSID]              INT           IDENTITY (1, 1) NOT NULL,
    [CLNO]                     INT           NOT NULL,
    [ParentCLNO]               INT           NULL,
    [ATS_Name]                 VARCHAR (200) NOT NULL,
    [DeliveryMethod]           VARCHAR (50)  NULL,
    [IntegrationType]          VARCHAR (50)  NULL,
    [IntegrationMethod]        VARCHAR (50)  NULL,
    [ReUsable]                 BIT           NULL,
    [Mode]                     VARCHAR (50)  NULL,
    [FirstIntegrationApp]      DATETIME      NULL,
    [Product/Service Impacted] VARCHAR (50)  NULL,
    [IsInActive]               BIT           CONSTRAINT [DF_ClientATS_IsInActive] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_ClientATS] PRIMARY KEY CLUSTERED ([ClientATSID] ASC) WITH (FILLFACTOR = 50)
);

