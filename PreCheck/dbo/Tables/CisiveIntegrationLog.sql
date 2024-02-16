CREATE TABLE [dbo].[CisiveIntegrationLog] (
    [CisiveIntegartionLogId] INT            IDENTITY (1, 1) NOT NULL,
    [RecordId]               INT            NULL,
    [SectionName]            VARCHAR (50)   NULL,
    [SectionId]              INT            NULL,
    [TableName]              VARCHAR (150)  CONSTRAINT [DF_CisiveIntegrationLogs_ApplicationName] DEFAULT (app_name()) NULL,
    [RequestDirection]       VARCHAR (8)    NOT NULL,
    [RequestMessage]         NVARCHAR (MAX) NOT NULL,
    [ResponseMessage]        NVARCHAR (MAX) NULL,
    [CisiveAPIId]            INT            NOT NULL,
    [HasError]               BIT            NOT NULL,
    [Message]                VARCHAR (MAX)  NULL,
    [Result]                 INT            NULL,
    [IsComplete]             BIT            NOT NULL,
    [CreateDate]             DATETIME       CONSTRAINT [DF_CisiveIntegrationLogs_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreateBy]               VARCHAR (20)   NOT NULL,
    [ModifyDate]             DATETIME       NULL,
    [ModifyBy]               VARCHAR (20)   NULL,
    CONSTRAINT [PK_CisiveIntegrationLogs_WorkOrderID] PRIMARY KEY CLUSTERED ([CisiveIntegartionLogId] ASC) WITH (FILLFACTOR = 70) ON [PRIMARY],
    CONSTRAINT [CHK_CisiveIntegrationLogs_RequestDirection] CHECK ([RequestDirection]='OUTBOUND' OR [RequestDirection]='INBOUND')
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];


GO
CREATE NONCLUSTERED INDEX [IX_CisiveIntegrationLog_RecordID]
    ON [dbo].[CisiveIntegrationLog]([RecordId] ASC)
    ON [PRIMARY];

