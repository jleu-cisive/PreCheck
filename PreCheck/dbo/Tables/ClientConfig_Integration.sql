CREATE TABLE [dbo].[ClientConfig_Integration] (
    [ClientConfig_IntegrationID] INT           IDENTITY (1, 1) NOT NULL,
    [CLNO]                       INT           NULL,
    [URL_CallBack_Acknowledge]   VARCHAR (500) NULL,
    [URL_CallBack_Final]         VARCHAR (500) NULL,
    [CallBackMethod]             VARCHAR (50)  NULL,
    [IntegrationMethod]          VARCHAR (50)  NULL,
    [ConfigSettings]             XML           NULL,
    [OperationName]              VARCHAR (50)  CONSTRAINT [DF_ClientConfig_Integration_OperationName] DEFAULT ('SendResponseWithUrl') NULL,
    [IsActive]                   BIT           DEFAULT ((0)) NULL,
    [refATSId]                   INT           NULL,
    CONSTRAINT [PK_ClientConfig_Integration] PRIMARY KEY CLUSTERED ([ClientConfig_IntegrationID] ASC)
) TEXTIMAGE_ON [PRIMARY];


GO
CREATE NONCLUSTERED INDEX [IX_ClientConfig_Integration_CLNO]
    ON [dbo].[ClientConfig_Integration]([CLNO] ASC, [refATSId] ASC);

