CREATE TABLE [dbo].[AIMS_StatusUpdate] (
    [AIMS_StatusUpdateId]          INT           IDENTITY (1, 1) NOT NULL,
    [AIMS_MappingId]               INT           NOT NULL,
    [Mozenda_JobKey]               VARCHAR (50)  NULL,
    [Mozenda_JobStatus]            VARCHAR (50)  NULL,
    [IsProcessed]                  BIT           NULL,
    [ProcessedDate]                DATETIME2 (7) NULL,
    [SearchOrderId]                INT           NULL,
    [AimsJobItemId]                INT           NULL,
    [DataXtract_LoggingId]         INT           NULL,
    [AIMSStatusUpdateDate]         DATETIME2 (7) NULL,
    [BatchId]                      INT           NULL,
    [AIMS_StatusUpdateCreatedDate] DATETIME2 (7) CONSTRAINT [df_ConstraintNAme] DEFAULT (getdate()) NULL,
    [CleanupDate]                  DATETIME2 (7) NULL,
    [RetryCount]                   INT           DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_AIMS_StatusUpdate] PRIMARY KEY CLUSTERED ([AIMS_StatusUpdateId] ASC) WITH (FILLFACTOR = 70)
);


GO
CREATE NONCLUSTERED INDEX [IDX_AIMS_StatusUpdate_AimsJobItemId]
    ON [dbo].[AIMS_StatusUpdate]([AimsJobItemId] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [AIMS_StatusUpdate_CleanupDate_ProcessedDate]
    ON [dbo].[AIMS_StatusUpdate]([CleanupDate] ASC, [ProcessedDate] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_AIMS_StatusUpdate_ProcessedDate_IsProcessed]
    ON [dbo].[AIMS_StatusUpdate]([ProcessedDate] ASC, [IsProcessed] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_AIMS_StatusUpdate_AIMS_MappingID_ProcessedDate_IsProcessed]
    ON [dbo].[AIMS_StatusUpdate]([AIMS_MappingId] ASC, [ProcessedDate] ASC, [IsProcessed] ASC)
    INCLUDE([AIMS_StatusUpdateId], [Mozenda_JobKey], [Mozenda_JobStatus], [SearchOrderId], [AimsJobItemId], [DataXtract_LoggingId], [AIMSStatusUpdateDate], [BatchId], [AIMS_StatusUpdateCreatedDate], [CleanupDate], [RetryCount]) WITH (FILLFACTOR = 95)
    ON [FG_INDEX];

