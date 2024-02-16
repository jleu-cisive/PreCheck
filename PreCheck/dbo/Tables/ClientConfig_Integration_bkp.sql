CREATE TABLE [dbo].[ClientConfig_Integration_bkp] (
    [ClientConfig_IntegrationID] INT           IDENTITY (1, 1) NOT NULL,
    [CLNO]                       INT           NULL,
    [URL_CallBack_Acknowledge]   VARCHAR (500) NULL,
    [URL_CallBack_Final]         VARCHAR (500) NULL,
    [CallBackMethod]             VARCHAR (50)  NULL,
    [IntegrationMethod]          VARCHAR (50)  NULL,
    [ConfigSettings]             XML           NULL,
    [OperationName]              VARCHAR (50)  NULL
);

