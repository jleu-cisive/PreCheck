CREATE TABLE [dbo].[PrecheckServiceLog] (
    [PrecheckServiceLogId] INT          IDENTITY (1, 1) NOT NULL,
    [ClientID]             INT          NOT NULL,
    [ClientAppNo]          VARCHAR (50) NULL,
    [ServiceDate]          DATETIME     NULL,
    [ServiceName]          VARCHAR (50) NULL,
    [Request]              XML          NULL,
    [apno]                 INT          NULL,
    [Response]             XML          NULL,
    PRIMARY KEY CLUSTERED ([PrecheckServiceLogId] ASC) WITH (FILLFACTOR = 70, DATA_COMPRESSION = PAGE)
) TEXTIMAGE_ON [PRIMARY];


GO
CREATE NONCLUSTERED INDEX [IDX_PrecheckServiceLog_ClientApno]
    ON [dbo].[PrecheckServiceLog]([ClientID] ASC, [ClientAppNo] ASC) WITH (FILLFACTOR = 80)
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [IDX_PreCheckServiceLog_APNO]
    ON [dbo].[PrecheckServiceLog]([apno] ASC) WITH (FILLFACTOR = 80)
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [IX_PreCheckServiceLog_ServiceDateServiceNameClientIdApNo]
    ON [dbo].[PrecheckServiceLog]([ServiceDate] ASC, [ServiceName] ASC, [ClientID] ASC, [apno] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_PrecheckServiceLog_ServiceName_ServiceDate]
    ON [dbo].[PrecheckServiceLog]([ServiceName] ASC, [ServiceDate] ASC)
    INCLUDE([apno])
    ON [FG_INDEX];

