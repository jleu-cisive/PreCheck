CREATE TABLE [dbo].[DataXtract_Logging] (
    [DataXtract_LoggingId] INT           IDENTITY (1, 1) NOT NULL,
    [SectionKeyId]         VARCHAR (50)  NOT NULL,
    [Section]              VARCHAR (100) NOT NULL,
    [Request]              VARCHAR (MAX) NULL,
    [Response]             VARCHAR (MAX) NULL,
    [ResponseError]        VARCHAR (MAX) NULL,
    [ResponseStatus]       VARCHAR (20)  NULL,
    [DateLogRequest]       DATETIME      NULL,
    [DateLogResponse]      DATETIME      NULL,
    [LogUser]              VARCHAR (30)  NULL,
    [ProcessDate]          DATETIME      NULL,
    [ProcessFlag]          BIT           NULL,
    [Total_Records]        INT           NULL,
    [Total_Clears]         INT           NULL,
    [Total_Exceptions]     INT           NULL,
    [Total_NoChange]       INT           NULL,
    [Total_NotFound]       INT           NULL,
    [Total_BoardAction]    INT           NULL,
    [AIMS_StatusUpdateId]  INT           NULL,
    [Parent_LoggingId]     INT           NULL,
    [Response_RecordCount] INT           NULL,
    [BatchId]              INT           NULL,
    CONSTRAINT [PK_DataXtract_Logging] PRIMARY KEY CLUSTERED ([DataXtract_LoggingId] ASC) WITH (DATA_COMPRESSION = PAGE)
) TEXTIMAGE_ON [PRIMARY];


GO
CREATE NONCLUSTERED INDEX [IX_DataXtract_Logging_Section_ProcessDate_ProcessFlag]
    ON [dbo].[DataXtract_Logging]([Section] ASC, [ProcessDate] ASC, [ProcessFlag] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IDX_DataXtract_Logging_AIMS_StatusUpdateId_Inc]
    ON [dbo].[DataXtract_Logging]([AIMS_StatusUpdateId] ASC)
    INCLUDE([DataXtract_LoggingId], [SectionKeyId], [Parent_LoggingId], [BatchId]) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_DataXtract_Logging_Date_Log_Request]
    ON [dbo].[DataXtract_Logging]([DateLogRequest] ASC)
    INCLUDE([DataXtract_LoggingId], [SectionKeyId], [Section], [ResponseError], [ResponseStatus], [DateLogResponse], [LogUser], [ProcessDate], [ProcessFlag], [Total_Records], [Total_Clears], [Total_Exceptions], [Total_NoChange], [Response_RecordCount], [AIMS_StatusUpdateId], [Parent_LoggingId]) WITH (FILLFACTOR = 90)
    ON [FG_INDEX];

