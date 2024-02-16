CREATE TABLE [dbo].[AIMS_BatchSettings] (
    [BatchSettingId]                 INT          IDENTITY (1, 1) NOT NULL,
    [Dataxtract_RequestMappingXMLId] INT          NOT NULL,
    [BatchType]                      VARCHAR (50) NULL,
    [IsBatchRetryEnabled]            BIT          NULL,
    PRIMARY KEY CLUSTERED ([BatchSettingId] ASC) WITH (FILLFACTOR = 70),
    FOREIGN KEY ([Dataxtract_RequestMappingXMLId]) REFERENCES [dbo].[DataXtract_RequestMapping] ([DataXtract_RequestMappingXMLID])
);

