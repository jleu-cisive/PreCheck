CREATE TABLE [dbo].[Integration_CallbackLogging] (
    [CallbackLogId]           INT           IDENTITY (1, 1) NOT NULL,
    [Clno]                    INT           NULL,
    [Apno]                    INT           NULL,
    [CallbackStatus]          VARCHAR (30)  NULL,
    [CallbackDate]            DATETIME      NULL,
    [CallbackPostResult]      XML           NULL,
    [CallbackError]           VARCHAR (MAX) NULL,
    [CallbackCompletedStatus] BIT           CONSTRAINT [DF_dbo.Integration_CallbackLogging_CallbackCompletedStatus] DEFAULT ((0)) NOT NULL,
    [CallbackPostRequest]     XML           NULL,
    [Partner_reference]       VARCHAR (200) NULL,
    [Action]                  VARCHAR (20)  NULL,
    [RequestId]               INT           NULL,
    CONSTRAINT [PK_Integration_CallbackLogging] PRIMARY KEY CLUSTERED ([CallbackLogId] ASC) WITH (DATA_COMPRESSION = PAGE)
);


GO
CREATE NONCLUSTERED INDEX [IDX_integration_CallbackLogging_APNO]
    ON [dbo].[Integration_CallbackLogging]([Apno] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IDX_Integration_CallbackLogging_CallbackStatus_CallbackDate_Inc]
    ON [dbo].[Integration_CallbackLogging]([CallbackStatus] ASC, [CallbackDate] ASC)
    INCLUDE([Apno], [CallbackCompletedStatus]) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_Integration_CallbackLogging_Clno_CallbackDate]
    ON [dbo].[Integration_CallbackLogging]([Clno] ASC, [CallbackDate] ASC)
    INCLUDE([Apno], [CallbackStatus]) WITH (FILLFACTOR = 95)
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [IDX_integration_CallbackLogging_CLNO_PartnerReference]
    ON [dbo].[Integration_CallbackLogging]([Clno] ASC, [Partner_reference] ASC)
    INCLUDE([CallbackStatus]);


GO
CREATE NONCLUSTERED INDEX [IDX_integration_CallbackLogging_RequestID]
    ON [dbo].[Integration_CallbackLogging]([RequestId] ASC);

